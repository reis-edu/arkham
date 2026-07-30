module Arkham
  module Presenters
    class ShiftItemCheckPresenter
      def initialize(check, viewer_group:)
        @check = check
        @viewer_group = viewer_group
      end

      def to_json
        {
          id: @check.id,
          shift_item_id: @check.shift_item_id,
          name: @check.shift_item_name,
          description: @check.shift_item_description,
          checked: @check.checked?,
          checked_by_id: @check.checked_by_id,
          checked_by_name: @check.checked_by_name,
          checked_by_login: @check.checked_by_login,
          checked_at: @check.checked_at,
          impossible: @check.impossible?,
          impossible_reason: @check.impossible_reason,
          review_status: @check.review_status,
          reviewed_by_id: @check.reviewed_by_id,
          reviewed_by_name: @check.reviewed_by_name,
          reviewed_by_login: @check.reviewed_by_login,
          reviewed_at: @check.reviewed_at
        }.merge(manager_only_fields)
      end

      private

      def manager_only_fields
        return {} unless ::User::SHIFT_MANAGER_GROUPS.include?(@viewer_group)

        { divergence_note: @check.divergence_note }
      end
    end
  end
end
