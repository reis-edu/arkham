# frozen_string_literal: true

module Arkham
  module Presenters
    class ShiftPresenter
      def initialize(shift, checks, viewer_group:)
        @shift = shift
        @checks = checks
        @viewer_group = viewer_group
      end

      def to_json(*_args)
        {
          id: @shift.id,
          shift_date: @shift.shift_date,
          shift_type: @shift.shift_type,
          status: @shift.status,
          execution_note: @shift.execution_note,
          execution_finalized_at: @shift.execution_finalized_at,
          execution_finalized_by_id: @shift.execution_finalized_by_id,
          review_finalized_at: @shift.review_finalized_at,
          review_finalized_by_id: @shift.review_finalized_by_id,
          items: @checks.map { |check| ShiftItemCheckPresenter.new(check, viewer_group: @viewer_group).to_json }
        }
      end
    end
  end
end
