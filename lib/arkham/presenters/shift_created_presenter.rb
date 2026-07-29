module Arkham
  module Presenters
    class ShiftCreatedPresenter
      def initialize(shift_id)
        @shift_id = shift_id
      end

      def to_json
        { id: @shift_id }
      end
    end
  end
end
