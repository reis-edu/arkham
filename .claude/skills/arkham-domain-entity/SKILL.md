---
name: arkham-domain-entity
description: Create domain entities and domain errors under lib/arkham/domain/ following Arkham's hexagonal architecture conventions. Use when adding a new domain concept (e.g. Visit, Activity, Checklist) or a new domain-level error for an existing entity.
---

# Arkham Domain Entity & Errors

Reference implementation: [lib/arkham/domain/entities/patient.rb](../../../lib/arkham/domain/entities/patient.rb) and [lib/arkham/domain/errors/patient_already_exists_error.rb](../../../lib/arkham/domain/errors/patient_already_exists_error.rb).

## Entity

Path: `lib/arkham/domain/entities/<entity>.rb`, module `Arkham::Domain::Entities::<Entity>`.

Rules:
- Plain Ruby object (no ActiveRecord inheritance). `attr_reader` for every attribute.
- `initialize(attributes = {})` reads each field from the hash with `attributes[:field]`. Give sane defaults inline where the domain has one (e.g. `attributes[:status] || 'active'`), never `nil`-check elsewhere for that field.
- Business logic that belongs to the entity itself (predicates, derived values) lives here as methods — not in use cases or presenters. Predicates end in `?` (`active?`). Derived values are plain methods (`age`, `fullname`).
- No validation logic in the entity — that belongs to the validator contract (see `arkham-validator`).

```ruby
module Arkham
  module Domain
    module Entities
      class <Entity>
        attr_reader :id, :field_one, :field_two

        def initialize(attributes = {})
          @id = attributes[:id]
          @field_one = attributes[:field_one]
          @field_two = attributes[:field_two]
        end
      end
    end
  end
end
```

## Domain errors

Path: `lib/arkham/domain/errors/<entity>_<reason>_error.rb`, module `Arkham::Domain::Errors::<Entity><Reason>Error`.

- One tiny class per error, always `< StandardError`. Most are one-liners:

```ruby
module Arkham
  module Domain
    module Errors
      class <Entity><Reason>Error < StandardError; end
    end
  end
end
```

- If the error needs to carry structured data (see `Validators::Errors::ApiValidationError`), override `initialize` to accept it and pass a message to `super` — and when raising it, pass just the instance (`raise MyError.new(data)`), never a second `raise` argument on top of it; see the "Raising an already-built exception instance" note in `arkham-use-case` for why that silently discards the message.
- A repository translating an expected persistence exception (e.g. `ActiveRecord::RecordInvalid`) into a domain error, per `arkham-repository`, is the same pattern as `Domain::Errors::PatientInvalidError` — a plain one-liner `StandardError` subclass, raised with the persistence layer's own error text.
- Every new domain error raised by a use case must be wired into `ApplicationController#rescue_from` with the right HTTP status — do this as part of `arkham-api-controller`, not here.
- `config/initializers/hexagonal_architecture.rb` requires everything under `lib/arkham/**/*.rb` **eagerly, in alphabetical path order** (not lazily, not in dependency order). Most files don't care, but if file A references a constant defined in file B at class-body-eval time (e.g. an `include`), and B sorts *after* A, A must `require_relative` B explicitly — don't assume alphabetical order happens to match dependency order. See the load-order note in `arkham-repository` for a concrete case this broke.
