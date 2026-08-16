# frozen_string_literal: true

module Arkham
  module Presenters
    class ShiftItemListPresenter
      def initialize(shift_items)
        @shift_items = shift_items
      end

      def to_json(*_args)
        { shift_items: @shift_items.map { |shift_item| ShiftItemPresenter.new(shift_item).to_json } }
      end
    end
  end
end
