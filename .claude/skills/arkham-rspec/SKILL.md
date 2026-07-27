---
name: arkham-rspec
description: Write RSpec specs for use cases and FactoryBot factories following Arkham's testing conventions (instance_double mocking, context structure). Use when adding tests for a new or changed use case, repository, or model.
---

# Arkham RSpec Conventions

Reference implementation: [spec/use_cases/create_patient_spec.rb](../../../spec/use_cases/create_patient_spec.rb), [spec/factories/patient.rb](../../../spec/factories/patient.rb).

## Use case specs

Path: `spec/use_cases/<verb>_<entity>_spec.rb`, `RSpec.describe Arkham::UseCases::<Verb><Entity>`.

- Repositories are always `instance_double('<Entity>Repository', ...)` — never real repository instances, never hit the database from a use-case spec.
- Stub `within_transaction` to just yield in every context that reaches a mutation: `allow(repo).to receive(:within_transaction) { |&block| block.call }`.
- Structure contexts around the same flow the use case itself follows, in this order:
  1. `'when params are valid'` — happy path, one `it` per observable effect (repo called with expected args, return value correct).
  2. `'when <entity> already exists'` / other business-rule failures — expect the specific domain error.
  3. `'when params are invalid'` — nested contexts: empty params, nil params (`ArgumentError`), missing required fields, wrong types, invalid enum values — each expects `Arkham::Validators::Errors::ApiValidationError` (or `ArgumentError` for nil).
  4. `'when database transaction fails'` / `'when repository fails'` — repo raises `ActiveRecord::RecordInvalid` / `StandardError`, use case propagates it unchanged.
  5. Any side-effect contexts (e.g. photo upload) as their own top-level `context`, including the failure/degraded sub-case.
- Use `let(:valid_params)` / `let(:expected_params)` at the top of the `describe '#execute'` block; keep each `it` to a single expectation.

## Factories

Path: `spec/factories/<entity>.rb`. `FactoryBot.define do factory :<entity>, class: '<Entity>' do ... end end`, plain field values (use existing helpers like `CpfUtils.cpf` for realistic-but-fake unique values), `trait :with_<association>` for building related records via `after(:build)`.

## Running

`bundle exec rspec spec/use_cases/<file>_spec.rb` for a single file; `bundle exec rspec` for the full suite.
