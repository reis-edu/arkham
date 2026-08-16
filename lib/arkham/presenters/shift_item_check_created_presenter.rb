# frozen_string_literal: true

module Arkham
  module Presenters
    class ShiftItemCheckCreatedPresenter
      def initialize(check_id)
        @check_id = check_id
      end

      def to_json(*_args)
        { id: @check_id }
      end
    end
  end
end
