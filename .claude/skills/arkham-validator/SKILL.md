---
name: arkham-validator
description: Create Dry::Validation API contracts under lib/arkham/validators/api/ following Arkham's conventions. Use when a use case needs to validate incoming params for a new or changed resource.
---

# Arkham Validator (Dry::Validation contract)

Reference implementation: [lib/arkham/validators/api/patient_contract.rb](../../../lib/arkham/validators/api/patient_contract.rb).

Path: `lib/arkham/validators/api/<entity>_contract.rb`, module `Arkham::Validators::Api::<Entity>Contract`, class `< Dry::Validation::Contract`.

## Structure

- `params do ... end` block declares shape and type only: `required(:field).filled(:str?)` for mandatory fields, `optional(:field).maybe(:str?)` for optional/nullable ones.
- Nested objects (e.g. an embedded photo payload) use `optional(:field).hash do ... end` with the same required/optional/maybe rules inside.
- Business-rule validation (enums, cross-field checks) goes in separate `rule(:field) do ... end` blocks below the `params` block — keep type/shape and business rules visually separate.
- Enum-style rules check `value` against a literal list and call `key.failure('message')` when invalid; guard optional fields with `if value.present?` first.

```ruby
module Arkham
  module Validators
    module Api
      class <Entity>Contract < Dry::Validation::Contract
        params do
          required(:field_one).filled(:str?)
          optional(:field_two).maybe(:str?)
        end

        rule(:field_two) do
          if value.present?
            unless %w[option_a option_b].include?(value)
              key.failure('must be one of: option_a, option_b')
            end
          end
        end
      end
    end
  end
end
```

## Wiring into a use case

Use cases call the contract directly, never controllers:

```ruby
def validate_params(params)
  result = Validators::Api::<Entity>Contract.new.call(params)
  if result.errors.any?
    raise Validators::Errors::ApiValidationError.new(result.errors.to_h), 'Params are not valid!'
  end

  result.to_h
end
```

`Validators::Errors::ApiValidationError` already exists and is generic — reuse it rather than creating a per-entity validation error. It's mapped to HTTP 422 in `ApplicationController` (see `arkham-api-controller`).
