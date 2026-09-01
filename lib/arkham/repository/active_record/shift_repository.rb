# frozen_string_literal: true

require_relative '../port'

module Arkham
  module Repository
    module ActiveRecord
      class ShiftRepository
        include Arkham::Repository::Port

        def within_transaction
          ::ActiveRecord::Base.transaction do
            yield if block_given?
          end
        end

        def find_all(_filter_params = {})
          ::Shift.order(shift_date: :desc).map { |shift| map_to_entity(shift) }
        end

        def find_by_id(id)
          shift = ::Shift.find_by(id: id)
          return nil unless shift

          map_to_entity(shift)
        end

        def find_current
          shift = ::Shift.where.not(status: 'review_finalized').order(shift_date: :desc, created_at: :desc).first
          shift ||= ::Shift.order(shift_date: :desc, created_at: :desc).first
          return nil unless shift

          map_to_entity(shift)
        end

        def find_last_by_type(shift_type)
          shift = ::Shift.where(shift_type: shift_type).order(shift_date: :desc, created_at: :desc).first
          return nil unless shift

          map_to_entity(shift)
        end

        def create(params)
          shift = ::Shift.create!(params)
          shift.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::ShiftInvalidError, e.record.errors.full_messages.join(', ')
        end

        def update(id, params)
          shift = ::Shift.find(id)
          shift.update!(params)
          shift.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::ShiftInvalidError, e.record.errors.full_messages.join(', ')
        end

        def destroy(id)
          shift = ::Shift.find(id)
          shift.destroy
          shift.id
        end

        def finalize_execution(id, execution_note:, by_id:)
          shift = ::Shift.find(id)
          shift.update!(
            status: 'execution_finalized',
            execution_note: execution_note,
            execution_finalized_at: Time.current,
            execution_finalized_by_id: by_id
          )
          shift.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::ShiftInvalidError, e.record.errors.full_messages.join(', ')
        end

        def finalize_review(id, by_id:)
          shift = ::Shift.find(id)
          shift.update!(
            status: 'review_finalized',
            review_finalized_at: Time.current,
            review_finalized_by_id: by_id
          )
          shift.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::ShiftInvalidError, e.record.errors.full_messages.join(', ')
        end

        private

        def map_to_entity(shift)
          Arkham::Domain::Entities::Shift.new(
            id: shift.id,
            shift_date: shift.shift_date,
            shift_type: shift.shift_type,
            title: shift.title,
            status: shift.status,
            execution_note: shift.execution_note,
            execution_finalized_at: shift.execution_finalized_at,
            execution_finalized_by_id: shift.execution_finalized_by_id,
            review_finalized_at: shift.review_finalized_at,
            review_finalized_by_id: shift.review_finalized_by_id
          )
        end
      end
    end
  end
end
