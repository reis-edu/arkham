module Arkham
  module Presenters
    class ShiftDivergenceListPresenter
      def initialize(checks)
        @checks = checks
      end

      def to_json
        {
          divergences: @checks.map do |check|
            {
              id: check.id,
              shift_item_id: check.shift_item_id,
              name: check.shift_item_name,
              description: check.shift_item_description,
              reviewed_by_id: check.reviewed_by_id,
              reviewed_by_name: check.reviewed_by_name,
              reviewed_by_login: check.reviewed_by_login,
              reviewed_at: check.reviewed_at,
              divergence_note: check.divergence_note
            }
          end
        }
      end
    end
  end
end
