# frozen_string_literal: true

module Arkham
  module Presenters
    class ShiftListPresenter
      def initialize(shifts)
        @shifts = shifts
      end

      def to_json(*_args)
        {
          shifts: @shifts.map do |shift|
            {
              id: shift.id,
              shift_date: shift.shift_date,
              shift_type: shift.shift_type,
              title: shift.title,
              status: shift.status,
              execution_finalized_at: shift.execution_finalized_at,
              review_finalized_at: shift.review_finalized_at
            }
          end
        }
      end
    end
  end
end
