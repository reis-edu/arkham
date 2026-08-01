require 'rails_helper'

RSpec.describe Arkham::UseCases::DestroyShiftItem do
  let(:shift_item_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemRepository) }
  let(:use_case) { described_class.new(shift_item_repository) }
  let(:shift_item_id) { SecureRandom.uuid }
  let(:shift_item) { Arkham::Domain::Entities::ShiftItem.new(id: shift_item_id) }

  before do
    allow(shift_item_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when the shift item exists and is not used in any shift' do
      before do
        allow(shift_item_repository).to receive(:find_by_id).with(shift_item_id).and_return(shift_item)
        allow(shift_item_repository).to receive(:used_in_any_shift?).with(shift_item_id).and_return(false)
        allow(shift_item_repository).to receive(:destroy).and_return(shift_item_id)
      end

      it 'destroys the shift item' do
        expect(shift_item_repository).to receive(:destroy).with(shift_item_id)
        use_case.execute(shift_item_id)
      end
    end

    context 'when the shift item does not exist' do
      before { allow(shift_item_repository).to receive(:find_by_id).and_return(nil) }

      it 'raises ShiftItemNotFoundError' do
        expect { use_case.execute(shift_item_id) }.to raise_error(Arkham::Domain::Errors::ShiftItemNotFoundError)
      end
    end

    context 'when the shift item is already used in a shift' do
      before do
        allow(shift_item_repository).to receive(:find_by_id).with(shift_item_id).and_return(shift_item)
        allow(shift_item_repository).to receive(:used_in_any_shift?).with(shift_item_id).and_return(true)
      end

      it 'raises ShiftItemInUseError and does not destroy it' do
        expect(shift_item_repository).not_to receive(:destroy)
        expect { use_case.execute(shift_item_id) }.to raise_error(Arkham::Domain::Errors::ShiftItemInUseError)
      end
    end
  end
end
