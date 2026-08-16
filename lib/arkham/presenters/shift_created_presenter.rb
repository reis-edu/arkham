# frozen_string_literal: true

module Arkham
  module Presenters
    class ShiftCreatedPresenter
      def initialize(shift_id)
        @shift_id = shift_id
      end

      def to_json(*_args)
        { id: @shift_id }
      end
    end
  end
end
