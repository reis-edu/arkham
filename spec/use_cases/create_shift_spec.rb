require 'rails_helper'

RSpec.describe Arkham::UseCases::CreateShift do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:shift_item_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemRepository) }
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:use_case) { described_class.new(shift_repository, shift_item_repository, shift_item_check_repository) }
  let(:valid_params) { { shift_date: '2026-07-28', shift_type: 'diurno' } }

  before do
    allow(shift_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when params are valid and there are active shift items' do
      let(:active_items) do
        [
          Arkham::Domain::Entities::ShiftItem.new(id: 'item-1'),
          Arkham::Domain::Entities::ShiftItem.new(id: 'item-2')
        ]
      end

      before do
        allow(shift_repository).to receive(:find_by_date_and_type).and_return(nil)
        allow(shift_repository).to receive(:create).and_return('shift-id')
        allow(shift_item_repository).to receive(:find_all_active).and_return(active_items)
        allow(shift_item_check_repository).to receive(:snapshot_for_shift)
      end

      it 'creates the shift and snapshots a check for every active item' do
        expect(shift_item_check_repository).to receive(:snapshot_for_shift).with('shift-id', %w[item-1 item-2])
        expect(use_case.execute(valid_params)).to eq('shift-id')
      end
    end

    context 'when there are no active shift items' do
      before do
        allow(shift_repository).to receive(:find_by_date_and_type).and_return(nil)
        allow(shift_repository).to receive(:create).and_return('shift-id')
        allow(shift_item_repository).to receive(:find_all_active).and_return([])
        allow(shift_item_check_repository).to receive(:snapshot_for_shift)
      end

      it 'still creates the shift, with an empty snapshot' do
        expect(shift_item_check_repository).to receive(:snapshot_for_shift).with('shift-id', [])
        use_case.execute(valid_params)
      end
    end

    context 'when a shift already exists for the same date and type' do
      before do
        allow(shift_repository).to receive(:find_by_date_and_type)
          .and_return(Arkham::Domain::Entities::Shift.new(id: 'other-id'))
      end

      it 'raises ShiftAlreadyExistsError and does not create anything' do
        expect(shift_repository).not_to receive(:create)
        expect { use_case.execute(valid_params) }.to raise_error(Arkham::Domain::Errors::ShiftAlreadyExistsError)
      end
    end

    context 'when params are invalid' do
      it 'raises ApiValidationError for an unknown shift_type' do
        expect { use_case.execute(shift_date: '2026-07-28', shift_type: 'madrugada') }
          .to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end
  end
end
