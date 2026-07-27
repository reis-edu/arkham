---
name: arkham-use-case
description: Create use case classes under lib/arkham/use_cases/ following Arkham's hexagonal architecture conventions (dependency injection, validation, transactions, domain errors). Use when implementing a new business operation (create/update/show/list/destroy/activate/etc.) for any resource.
---

# Arkham Use Case

Reference implementations: [lib/arkham/use_cases/create_patient.rb](../../../lib/arkham/use_cases/create_patient.rb), [lib/arkham/use_cases/update_patient.rb](../../../lib/arkham/use_cases/update_patient.rb), [lib/arkham/use_cases/list_patients.rb](../../../lib/arkham/use_cases/list_patients.rb), [lib/arkham/use_cases/show_patient.rb](../../../lib/arkham/use_cases/show_patient.rb).

Path: `lib/arkham/use_cases/<verb>_<entity>.rb`, module `Arkham::UseCases::<Verb><Entity>` (`CreatePatient`, `UpdatePatient`, `ShowPatient`, `ListPatients`, `DestroyPatient`, `ActivatePatient`/`InactivatePatient`, `Get<Thing>` for read-only cross-cutting operations).

## Shape

- One class per operation, one public method: `execute`. Everything else is `private`.
- Constructor takes already-instantiated repositories as plain arguments (no framework DI container) — resolved from `Arkham::Dependencies` by the caller, never instantiated inside the use case:

```ruby
def initialize(<entity>_repository, other_repository = nil)
  @<entity>_repository = <entity>_repository
  @other_repository = other_repository
end
```

- `execute` reads top to bottom as the business flow: validate → check business rules → mutate (in a transaction) → return. Keep it a short sequence of calls to private helpers, not inline logic.

```ruby
def execute(params)
  validated = validate_params(params)
  check_duplicate(validated[:unique_field])

  @<entity>_repository.within_transaction do
    id = @<entity>_repository.create(validated)
    id
  end
end
```

- Only wrap in `within_transaction` when the operation does more than one write (e.g. create record + save photo + update record). A single-write or read-only use case (`ShowPatient`, `ListPatients`) does not need a transaction at all.
- Validation: delegate to the matching `Validators::Api::<Entity>Contract` (see `arkham-validator`), raise `Validators::Errors::ApiValidationError` with `.errors.to_h` on failure.
- Business-rule/not-found checks raise domain errors (see `arkham-domain-entity`), e.g. `Domain::Errors::<Entity>AlreadyExistsError`, `Domain::Errors::<Entity>NotFoundError`. Never raise a raw `StandardError` or return `nil`/`false` for an error case — the controller only knows how to translate domain errors into HTTP responses.
- `find_<entity>` private helper: fetch by id, raise `NotFoundError` if absent, return the entity — reuse this same helper in every use case that needs "the record must already exist" (Update, Destroy, Activate, Inactivate).
- Every mutating use case (including single-write ones like `DestroyPatient`) must run its writes through `@<entity>_repository.within_transaction`, never a raw `ActiveRecord::Base.transaction` — the repository owns the transaction mechanism, not the use case.

### Raising an already-built exception instance

When an error class carries structured data (e.g. `ApiValidationError.new(errors_hash)`), raise the instance on its own — **do not** also pass a message as the second `raise` argument:

```ruby
# Wrong: the second arg silently replaces the message `initialize` built via `super(...)`
raise Validators::Errors::ApiValidationError.new(errors), 'Params are not valid!'

# Right: let the custom initialize's message stand
raise Validators::Errors::ApiValidationError.new(errors)
```
`raise(instance, message)` calls `instance.exception(message)`, which discards whatever message `initialize` constructed. This is easy to miss because `.errors`/other ivars still survive (via `dup`) — only `.message` silently goes wrong.

## When a side effect is shared across use cases (e.g. a photo upload)

If only one use case needs the side effect, a small private method is fine. If more than one use case needs the **same** side effect (e.g. both `CreatePatient` and `UpdatePatient` need to save a photo and update the record with the result), extract it into its own use case instead of duplicating the private methods — see `lib/arkham/use_cases/save_patient_photo.rb`:

- `Arkham::UseCases::Save<Entity><Thing>` takes the same repositories, exposes one `execute(id, payload)`.
- The use cases that need it take it as an extra constructor argument, **defaulted** to building its own instance from the repositories already injected — this keeps existing 2-arg call sites (and their specs) working unchanged while `Dependencies` can also wire a shared instance explicitly:

```ruby
def initialize(<entity>_repository, other_repository, save_thing = Save<Entity><Thing>.new(<entity>_repository, other_repository))
  @<entity>_repository = <entity>_repository
  @save_thing = save_thing
end
```

Call it inside the same transaction, after the primary write: `@save_thing.execute(id, payload) if payload.present?`.

## Wiring

Register the new use case in `lib/arkham/dependencies.rb` as a memoized class method, and inject it into the controller from there — see `arkham-api-controller`.
