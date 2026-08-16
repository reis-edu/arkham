# frozen_string_literal: true

module Arkham
  module UseCases
    class ListShiftItems
      def initialize(shift_item_repository)
        @shift_item_repository = shift_item_repository
      end

      def execute(filter_params = {})
        @shift_item_repository.find_all(filter_params)
      end
    end
  end
end
