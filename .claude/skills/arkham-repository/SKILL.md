---
name: arkham-repository
description: Create ActiveRecord repositories, filter/query-object repositories, and external-service repositories under lib/arkham/repository/ following Arkham's hexagonal architecture conventions. Use when a use case needs data access to Postgres or an external service (e.g. S3/Filebase, WhatsApp provider).
---

# Arkham Repository

Reference implementations: [lib/arkham/repository/active_record/patient_repository.rb](../../../lib/arkham/repository/active_record/patient_repository.rb), [lib/arkham/repository/active_record/patient_filter_repository.rb](../../../lib/arkham/repository/active_record/patient_filter_repository.rb), [lib/arkham/repository/filebase/patient_photo_repository.rb](../../../lib/arkham/repository/filebase/patient_photo_repository.rb).

The repository is the **only** layer allowed to touch ActiveRecord models or external clients. Use cases and presenters only ever see domain entities.

## ActiveRecord repository

Path: `lib/arkham/repository/active_record/<entity>_repository.rb`, module `Arkham::Repository::ActiveRecord::<Entity>Repository`.

- Public methods map 1:1 to what use cases need: `find_all(filter_params = {})`, `find_by_id(id)`, `create(params)`, `update(id, params)`, `destroy(id)`, plus custom finders/actions the domain needs (`find_by_cpf`, `activate`, `inactivate`).
- `create`/`update`/`activate`/`inactivate` return the record `id`, not the AR object.
- `find_by_id`/custom finders return `nil` when not found (let the use case decide whether that's an error) or a mapped domain entity otherwise — never the raw AR model.
- Every repository exposes `within_transaction(&block)` wrapping `::ActiveRecord::Base.transaction { yield if block_given? }`. Use cases call this instead of touching `ActiveRecord::Base` directly — including single-write use cases (e.g. `DestroyPatient`), not just multi-write ones.
- Private `map_to_entity(record)` builds the `Arkham::Domain::Entities::<Entity>` from the AR record — this is the one place field names are translated.
- `create`/`update` must rescue `ActiveRecord::RecordInvalid` and re-raise as a domain error (`Domain::Errors::<Entity>InvalidError`, see `arkham-domain-entity`) — never let it leak to the use case. Only rescue that specific exception; do **not** rescue generic `StandardError` here, or an unexpected error (lost DB connection, etc.) silently turns into a handled domain error instead of surfacing as a 500.
- Include `Arkham::Repository::Port` (`lib/arkham/repository/port.rb`) to document the contract every AR repository must implement. See the load-order note below — it must be required explicitly, not relied on via file sort order.

```ruby
require_relative '../port'

module Arkham
  module Repository
    module ActiveRecord
      class <Entity>Repository
        include Arkham::Repository::Port

        def within_transaction(&block)
          ::ActiveRecord::Base.transaction do
            yield if block_given?
          end
        end

        def find_all(filter_params = {})
          records = <Entity>FilterRepository.new.call(filter_params)
          records.map { |record| map_to_entity(record) }
        end

        def find_by_id(id)
          record = ::<Entity>.find_by(id: id)
          return nil unless record

          map_to_entity(record)
        end

        def create(params)
          record = ::<Entity>.create!(params)
          record.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::<Entity>InvalidError, e.record.errors.full_messages.join(', ')
        end

        def update(id, params)
          record = ::<Entity>.find(id)
          record.update!(params)
          record.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::<Entity>InvalidError, e.record.errors.full_messages.join(', ')
        end

        def destroy(id)
          ::<Entity>.find(id).destroy
        end

        private

        def map_to_entity(record)
          Arkham::Domain::Entities::<Entity>.new(
            id: record.id
            # ...map remaining fields
          )
        end
      end
    end
  end
end
```

### Load-order gotcha with `Arkham::Repository::Port`

`config/initializers/hexagonal_architecture.rb` eagerly `require`s every `lib/arkham/**/*.rb` file in **alphabetical path order**, not in dependency order. `repository/active_record/<entity>_repository.rb` sorts *before* `repository/port.rb` (`active_record` < `port`), so a bare `include Arkham::Repository::Port` in the AR repository raises `NameError: uninitialized constant` at boot — this was caught empirically while fixing the reference implementation, not by inspection. Always add `require_relative '../port'` at the top of the AR repository file rather than assuming load order.

## Filter/query repository

Only add one when `find_all` needs non-trivial filtering. Path: `lib/arkham/repository/active_record/<entity>_filter_repository.rb`.

- Single public `call(search_params)` that builds `@relation` incrementally through private `filter_by_*` methods, one per filterable field, and returns the relation (not mapped entities — the caller repository maps).
- Encode allowed values as a frozen constant (`AVAILABLE_STATUS = ['active', 'inactive'].freeze`) and validate against it before applying the filter.
- Apply a sensible default filter when the param is absent (e.g. default to `status = 'active'`) rather than returning everything.

## External-service repository

Path: `lib/arkham/repository/<provider>/<entity>_<thing>_repository.rb` (e.g. `filebase/patient_photo_repository.rb`).

- Wraps the external SDK/client entirely; nothing outside this class touches the provider's API.
- Reads credentials/config from `Arkham.config[:<provider>][...]` (see `config/arkham.yml`), never from `ENV` directly in the repository body.
- Rescues the provider's errors and re-raises as a domain error (`Domain::Errors::<Entity><Thing>Error`) so callers only ever handle Arkham errors.
- If the operation is cacheable and idempotent (e.g. presigned URLs), use `Rails.cache.fetch` with an expiration pulled from `Arkham.config`.
