# frozen_string_literal: true

module Arkham
  module Repository
    module ActiveRecord
      class ShiftItemCheckRepository
        def within_transaction
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

        def create(shift_id, shift_item_id)
          check = ::ShiftItemCheck.create!(
            shift_id: shift_id, shift_item_id: shift_item_id,
            checked: false, impossible: false, review_status: 'pending'
          )
          check.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::ShiftItemCheckInvalidError, e.record.errors.full_messages.join(', ')
        end

        def destroy(id)
          check = ::ShiftItemCheck.find(id)
          check.destroy
          check.id
        end

        def find_by_id(id)
          check = ::ShiftItemCheck.includes(:shift_item, :checked_by, :reviewed_by).find_by(id: id)
          return nil unless check

          map_to_entity(check)
        end

        def find_by_shift_and_item(shift_id, shift_item_id)
          check = ::ShiftItemCheck.includes(:shift_item, :checked_by, :reviewed_by)
                                  .find_by(shift_id: shift_id, shift_item_id: shift_item_id)
          return nil unless check

          map_to_entity(check)
        end

        def find_all_for_shift(shift_id)
          ::ShiftItemCheck.includes(:shift_item, :checked_by, :reviewed_by)
                          .where(shift_id: shift_id)
                          .map { |check| map_to_entity(check) }
        end

        def divergences_for_shift(shift_id)
          ::ShiftItemCheck.includes(:shift_item, :checked_by, :reviewed_by)
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

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def map_to_entity(check)
          Arkham::Domain::Entities::ShiftItemCheck.new(
            id: check.id,
            shift_id: check.shift_id,
            shift_item_id: check.shift_item_id,
            shift_item_name: check.shift_item&.name,
            shift_item_description: check.shift_item&.description,
            checked: check.checked,
            checked_by_id: check.checked_by_id,
            checked_by_name: check.checked_by&.name,
            checked_by_login: check.checked_by&.login,
            checked_at: check.checked_at,
            impossible: check.impossible,
            impossible_reason: check.impossible_reason,
            review_status: check.review_status,
            reviewed_by_id: check.reviewed_by_id,
            reviewed_by_name: check.reviewed_by&.name,
            reviewed_by_login: check.reviewed_by&.login,
            reviewed_at: check.reviewed_at,
            divergence_note: check.divergence_note
          )
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
      end
    end
  end
end
