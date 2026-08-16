# frozen_string_literal: true

module Arkham
  module Presenters
    class ShiftItemCreatedPresenter
      def initialize(shift_item_id)
        @shift_item_id = shift_item_id
      end

      def to_json(*_args)
        { id: @shift_item_id }
      end
    end
  end
end
