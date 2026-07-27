---
name: arkham-presenter
description: Create JSON presenters under lib/arkham/presenters/ following Arkham's conventions for serializing domain entities in API responses. Use when a controller needs to render a new resource or a new shape of an existing one.
---

# Arkham Presenter

Reference implementations: [lib/arkham/presenters/patient_presenter.rb](../../../lib/arkham/presenters/patient_presenter.rb), [lib/arkham/presenters/patient_list_presenter.rb](../../../lib/arkham/presenters/patient_list_presenter.rb).

Path: `lib/arkham/presenters/<entity>_presenter.rb`, module `Arkham::Presenters::<Entity>Presenter`.

## Single-record presenter

- Constructor takes the domain entity. Single public method `to_json` returning a plain **Hash** (not an actual JSON string — the name is the project convention, keep using it).
- Only exposes fields the API contract needs — including derived entity methods (`fullname`, `age`, `active?`) alongside stored attributes.
- If a field requires a side call (e.g. a presigned URL), pull the use case from `Arkham::Dependencies` in the constructor and compute it in a private method, guarding on presence first:

```ruby
module Arkham
  module Presenters
    class <Entity>Presenter
      def initialize(<entity>)
        @<entity> = <entity>
      end

      def to_json
        {
          id: @<entity>.id,
          field_one: @<entity>.field_one
        }
      end
    end
  end
end
```

## List presenter

Path: `lib/arkham/presenters/<entity>_list_presenter.rb`. Wraps a collection by delegating each item to the single-record presenter — never duplicate field mapping here:

```ruby
module Arkham
  module Presenters
    class <Entity>ListPresenter
      def initialize(<entities>)
        @<entities> = <entities>
      end

      def to_json
        {
          <entities>: @<entities>.map { |e| <Entity>Presenter.new(e).to_json }
        }
      end
    end
  end
end
```

## Created/Updated presenters

For `create`/`update`/`activate`/`inactivate` actions that only need to echo back an id, use a minimal dedicated presenter (`<Entity>CreatedPresenter`, `<Entity>UpdatedPresenter`) rather than reusing the full presenter — see `patient_created_presenter.rb` for the pattern.
