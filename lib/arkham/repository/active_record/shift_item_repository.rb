# frozen_string_literal: true

require_relative '../port'

module Arkham
  module Repository
    module ActiveRecord
      class ShiftItemRepository
        include Arkham::Repository::Port

        def within_transaction
          ::ActiveRecord::Base.transaction do
            yield if block_given?
          end
        end

        def find_all(_filter_params = {})
          ::ShiftItem.order(:name).map { |shift_item| map_to_entity(shift_item) }
        end

        def find_all_active
          ::ShiftItem.active.order(:name).map { |shift_item| map_to_entity(shift_item) }
        end

        def find_by_id(id)
          shift_item = ::ShiftItem.find_by(id: id)
          return nil unless shift_item

          map_to_entity(shift_item)
        end

        def find_by_name(name)
          shift_item = ::ShiftItem.find_by(name: name)
          return nil unless shift_item

          map_to_entity(shift_item)
        end

        def create(params)
          shift_item = ::ShiftItem.create!(params)
          shift_item.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::ShiftItemInvalidError, e.record.errors.full_messages.join(', ')
        end

        def update(id, params)
          shift_item = ::ShiftItem.find(id)
          shift_item.update!(params)
          shift_item.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::ShiftItemInvalidError, e.record.errors.full_messages.join(', ')
        end

        def destroy(id)
          shift_item = ::ShiftItem.find(id)
          shift_item.destroy
          shift_item.id
        rescue ::ActiveRecord::DeleteRestrictionError
          raise Domain::Errors::ShiftItemInUseError, 'Shift item is already used in a shift and cannot be removed'
        end

        def used_in_any_shift?(id)
          ::ShiftItemCheck.exists?(shift_item_id: id)
        end

        def all_exist?(ids)
          ids = ids.uniq
          ::ShiftItem.where(id: ids).count == ids.size
        end

        private

        def map_to_entity(shift_item)
          Arkham::Domain::Entities::ShiftItem.new(
            id: shift_item.id,
            name: shift_item.name,
            description: shift_item.description,
            active: shift_item.active
          )
        end
      end
    end
  end
end
