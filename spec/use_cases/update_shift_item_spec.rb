require 'rails_helper'

RSpec.describe Arkham::UseCases::UpdateShiftItem do
  let(:shift_item_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemRepository) }
  let(:use_case) { described_class.new(shift_item_repository) }
  let(:shift_item_id) { SecureRandom.uuid }
  let(:shift_item) { Arkham::Domain::Entities::ShiftItem.new(id: shift_item_id, name: 'Antigo nome', active: true) }

  before do
    allow(shift_item_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when params are valid and the name is not taken' do
      before do
        allow(shift_item_repository).to receive(:find_by_id).with(shift_item_id).and_return(shift_item)
        allow(shift_item_repository).to receive(:find_by_name).with('Novo nome').and_return(nil)
        allow(shift_item_repository).to receive(:update).and_return(shift_item_id)
      end

      it 'updates the shift item and returns its id' do
        expect(shift_item_repository).to receive(:update).with(shift_item_id, hash_including(name: 'Novo nome'))
        expect(use_case.execute(shift_item_id, { name: 'Novo nome' })).to eq(shift_item_id)
      end
    end

    context 'when only toggling active (no name change)' do
      before do
        allow(shift_item_repository).to receive(:find_by_id).with(shift_item_id).and_return(shift_item)
        allow(shift_item_repository).to receive(:update).and_return(shift_item_id)
      end

      it 'does not check for duplicate names' do
        expect(shift_item_repository).not_to receive(:find_by_name)
        use_case.execute(shift_item_id, { active: false })
      end
    end

    context 'when the shift item does not exist' do
      before { allow(shift_item_repository).to receive(:find_by_id).and_return(nil) }

      it 'raises ShiftItemNotFoundError' do
        expect { use_case.execute(shift_item_id, { name: 'x' }) }.to raise_error(Arkham::Domain::Errors::ShiftItemNotFoundError)
      end
    end

    context 'when renaming to a name already used by another shift item' do
      before do
        allow(shift_item_repository).to receive(:find_by_id).with(shift_item_id).and_return(shift_item)
        allow(shift_item_repository).to receive(:find_by_name).with('Nome em uso')
          .and_return(Arkham::Domain::Entities::ShiftItem.new(id: 'other-id', name: 'Nome em uso'))
      end

      it 'raises ShiftItemAlreadyExistsError' do
        expect(shift_item_repository).not_to receive(:update)
        expect { use_case.execute(shift_item_id, { name: 'Nome em uso' }) }
          .to raise_error(Arkham::Domain::Errors::ShiftItemAlreadyExistsError)
      end
    end
  end
end
