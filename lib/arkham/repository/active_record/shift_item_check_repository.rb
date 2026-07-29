module Arkham
  module Repository
    module ActiveRecord
      class ShiftItemCheckRepository
        def within_transaction(&block)
          ::ActiveRecord::Base.transaction do
            yield if block_given?
          end
        end

        def snapshot_for_shift(shift_id, shift_item_ids)
          now = Time.current
          rows = shift_item_ids.map do |shift_item_id|
            {
              id: SecureRandom.uuid,
              shift_id: shift_id,
              shift_item_id: shift_item_id,
              checked: false,
              impossible: false,
              review_status: 'pending',
              created_at: now,
              updated_at: now
            }
          end
          ::ShiftItemCheck.insert_all(rows) if rows.any?
        end

        def find_by_id(id)
          check = ::ShiftItemCheck.includes(:shift_item).find_by(id: id)
          return nil unless check

          map_to_entity(check)
        end

        def find_by_shift_and_item(shift_id, shift_item_id)
          check = ::ShiftItemCheck.includes(:shift_item).find_by(shift_id: shift_id, shift_item_id: shift_item_id)
          return nil unless check

          map_to_entity(check)
        end

        def find_all_for_shift(shift_id)
          ::ShiftItemCheck.includes(:shift_item).where(shift_id: shift_id).map { |check| map_to_entity(check) }
        end

        def divergences_for_shift(shift_id)
          ::ShiftItemCheck.includes(:shift_item)
                          .where(shift_id: shift_id, review_status: 'divergent')
                          .map { |check| map_to_entity(check) }
        end

        def update_check(id, attributes)
          check = ::ShiftItemCheck.find(id)
          check.update!(attributes)
          check.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::ShiftItemCheckInvalidError, e.record.errors.full_messages.join(', ')
        end

        def update_review(id, attributes)
          check = ::ShiftItemCheck.find(id)
          check.update!(attributes)
          check.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::ShiftItemCheckInvalidError, e.record.errors.full_messages.join(', ')
        end

        private

        def map_to_entity(check)
          Arkham::Domain::Entities::ShiftItemCheck.new(
            id: check.id,
            shift_id: check.shift_id,
            shift_item_id: check.shift_item_id,
            shift_item_name: check.shift_item&.name,
            shift_item_description: check.shift_item&.description,
            checked: check.checked,
            checked_by_id: check.checked_by_id,
            checked_at: check.checked_at,
            impossible: check.impossible,
            impossible_reason: check.impossible_reason,
            review_status: check.review_status,
            reviewed_by_id: check.reviewed_by_id,
            reviewed_at: check.reviewed_at,
            divergence_note: check.divergence_note
          )
        end
      end
    end
  end
end
