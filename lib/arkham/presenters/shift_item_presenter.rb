module Arkham
  module Presenters
    class ShiftItemPresenter
      def initialize(shift_item)
        @shift_item = shift_item
      end

      def to_json
        {
          id: @shift_item.id,
          name: @shift_item.name,
          description: @shift_item.description,
          active: @shift_item.active?
        }
      end
    end
  end
end
