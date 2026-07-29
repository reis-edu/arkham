module Arkham
  module Presenters
    class ShiftItemCheckCreatedPresenter
      def initialize(check_id)
        @check_id = check_id
      end

      def to_json
        { id: @check_id }
      end
    end
  end
end
