require 'rails_helper'

RSpec.describe Arkham::UseCases::AddShiftItem do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:shift_item_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemRepository) }
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:use_case) { described_class.new(shift_repository, shift_item_repository, shift_item_check_repository) }
  let(:shift_id) { SecureRandom.uuid }
  let(:shift_item_id) { SecureRandom.uuid }

  before do
    allow(shift_item_check_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when the shift is open, the item exists and is not yet in the shift' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'open') }
      let(:shift_item) { Arkham::Domain::Entities::ShiftItem.new(id: shift_item_id) }

      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_item_repository).to receive(:find_by_id).with(shift_item_id).and_return(shift_item)
        allow(shift_item_check_repository).to receive(:find_by_shift_and_item).with(shift_id, shift_item_id).and_return(nil)
        allow(shift_item_check_repository).to receive(:create).and_return('check-id')
      end

      it 'creates a check for the item' do
        expect(shift_item_check_repository).to receive(:create).with(shift_id, shift_item_id)
        expect(use_case.execute(shift_id, shift_item_id: shift_item_id)).to eq('check-id')
      end
    end

    context 'when the shift does not exist' do
      before { allow(shift_repository).to receive(:find_by_id).and_return(nil) }

      it 'raises ShiftNotFoundError' do
        expect { use_case.execute(shift_id, shift_item_id: shift_item_id) }.to raise_error(Arkham::Domain::Errors::ShiftNotFoundError)
      end
    end

    context 'when the shift is not open anymore' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'execution_finalized') }

      before { allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift) }

      it 'raises ShiftAlreadyFinalizedError and does not create anything' do
        expect(shift_item_check_repository).not_to receive(:create)
        expect { use_case.execute(shift_id, shift_item_id: shift_item_id) }
          .to raise_error(Arkham::Domain::Errors::ShiftAlreadyFinalizedError)
      end
    end

    context 'when the shift item does not exist' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'open') }

      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_item_repository).to receive(:find_by_id).with(shift_item_id).and_return(nil)
      end

      it 'raises ShiftItemNotFoundError' do
        expect { use_case.execute(shift_id, shift_item_id: shift_item_id) }.to raise_error(Arkham::Domain::Errors::ShiftItemNotFoundError)
      end
    end

    context 'when the item is already part of the shift' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'open') }
      let(:shift_item) { Arkham::Domain::Entities::ShiftItem.new(id: shift_item_id) }

      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_item_repository).to receive(:find_by_id).with(shift_item_id).and_return(shift_item)
        allow(shift_item_check_repository).to receive(:find_by_shift_and_item)
          .and_return(Arkham::Domain::Entities::ShiftItemCheck.new(id: 'existing-check'))
      end

      it 'raises ShiftItemCheckAlreadyExistsError' do
        expect(shift_item_check_repository).not_to receive(:create)
        expect { use_case.execute(shift_id, shift_item_id: shift_item_id) }
          .to raise_error(Arkham::Domain::Errors::ShiftItemCheckAlreadyExistsError)
      end
    end

    context 'when params are invalid' do
      it 'raises ApiValidationError when shift_item_id is missing' do
        expect { use_case.execute(shift_id, {}) }.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end
  end
end
