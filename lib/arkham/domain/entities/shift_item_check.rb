# frozen_string_literal: true

module Arkham
  module Domain
    module Entities
      class ShiftItemCheck
        attr_reader :id, :shift_id, :shift_item_id, :shift_item_name, :shift_item_description,
                    :checked, :checked_by_id, :checked_by_name, :checked_by_login, :checked_at,
                    :impossible, :impossible_reason,
                    :review_status, :reviewed_by_id, :reviewed_by_name, :reviewed_by_login,
                    :reviewed_at, :divergence_note

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def initialize(attributes = {})
          @id = attributes[:id]
          @shift_id = attributes[:shift_id]
          @shift_item_id = attributes[:shift_item_id]
          @shift_item_name = attributes[:shift_item_name]
          @shift_item_description = attributes[:shift_item_description]
          @checked = attributes[:checked]
          @checked_by_id = attributes[:checked_by_id]
          @checked_by_name = attributes[:checked_by_name]
          @checked_by_login = attributes[:checked_by_login]
          @checked_at = attributes[:checked_at]
          @impossible = attributes[:impossible]
          @impossible_reason = attributes[:impossible_reason]
          @review_status = attributes[:review_status] || 'pending'
          @reviewed_by_id = attributes[:reviewed_by_id]
          @reviewed_by_name = attributes[:reviewed_by_name]
          @reviewed_by_login = attributes[:reviewed_by_login]
          @reviewed_at = attributes[:reviewed_at]
          @divergence_note = attributes[:divergence_note]
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        def checked?
          @checked
        end

        def impossible?
          @impossible
        end

        def divergent?
          @review_status == 'divergent'
        end
      end
    end
  end
end
