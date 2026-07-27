---
name: arkham-api-controller
description: Create thin Rails API controllers under app/controllers/api/, wire routes, register dependencies, and map domain errors to HTTP statuses following Arkham's conventions. Use when exposing a use case over HTTP for a new or existing resource.
---

# Arkham API Controller

Reference implementations: [app/controllers/api/patients_controller.rb](../../../app/controllers/api/patients_controller.rb), [app/controllers/application_controller.rb](../../../app/controllers/application_controller.rb), [config/routes.rb](../../../config/routes.rb), [lib/arkham/dependencies.rb](../../../lib/arkham/dependencies.rb).

## Controller

Path: `app/controllers/api/<entities>_controller.rb`, plain `module Api` (not `Arkham::`), `class <Entities>Controller < ApplicationController`.

- `initialize` resolves every use case the controller needs from `Arkham::Dependencies` into `@<verb>_<entity>_use_case` ivars — no use case is ever instantiated inline in an action.
- Every action is 2-3 lines: extract params → call the use case → render via a presenter (see `arkham-presenter`). No business logic, no rescue blocks (that's `ApplicationController`'s job).
- `destroy` renders `head(:ok)` with no body.
- Strong params: `params.require(:<entity>).permit!` for nested create/update payloads (validation is the contract's job, not strong params'); `params.except(:format, :action, :controller, :application).permit(:field_one, :field_two).to_h` for flat filter params on `index`.

```ruby
module Api
  class <Entities>Controller < ApplicationController
    def initialize(_ = {})
      @create_<entity>_use_case = Arkham::Dependencies.create_<entity>_use_case
    end

    def create
      <entity>_params = permitted_params.to_h
      id = @create_<entity>_use_case.execute(<entity>_params)

      render json: Arkham::Presenters::<Entity>CreatedPresenter.new(id).to_json
    end

    private

    def permitted_params
      params.require(:<entity>).permit!
    end
  end
end
```

## Routes

Add to the `namespace :api, defaults: { format: 'json' } do ... end` block in `config/routes.rb`. Use `resources <entities>, only: %i[...]` for standard CRUD, and explicit `put '/<entities>/:id/<action>', to: '<entities>#<action>'` for non-CRUD state transitions (mirrors `activate`/`inactivate`).

## Registering dependencies

Add a memoized class method per repository and per use case to `lib/arkham/dependencies.rb`, following the existing `||=` pattern. Repositories are memoized once and shared across the use cases that need them.

## Mapping domain errors to HTTP

Every new `Domain::Errors::*` or reused `Validators::Errors::*` raised by a use case needs a `rescue_from` in `ApplicationController`:

```ruby
rescue_from Arkham::Domain::Errors::<Entity><Reason>Error do |e|
  render json: { error: e.message }, status: :<http_status>
end
```

Status conventions already in use: not-found → `:not_found`, already-exists / invalid business state / validation failure → `:unprocessable_entity`. Don't invent ad-hoc status codes without checking these conventions first.
