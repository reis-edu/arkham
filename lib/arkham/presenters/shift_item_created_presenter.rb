module Arkham
  module Presenters
    class ShiftItemCreatedPresenter
      def initialize(shift_item_id)
        @shift_item_id = shift_item_id
      end

      def to_json
        { id: @shift_item_id }
      end
    end
  end
end
