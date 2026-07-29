require 'rails_helper'

RSpec.describe Arkham::UseCases::CreateShiftItem do
  let(:shift_item_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemRepository) }
  let(:use_case) { described_class.new(shift_item_repository) }
  let(:valid_params) { { name: 'Aferir pressão', description: 'Checar PA do paciente' } }

  before do
    allow(shift_item_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when params are valid' do
      before do
        allow(shift_item_repository).to receive(:find_by_name).with('Aferir pressão').and_return(nil)
        allow(shift_item_repository).to receive(:create).and_return('shift-item-id')
      end

      it 'creates the shift item and returns its id' do
        expect(shift_item_repository).to receive(:create).with(hash_including(name: 'Aferir pressão'))
        expect(use_case.execute(valid_params)).to eq('shift-item-id')
      end
    end

    context 'when a shift item with the same name already exists' do
      before do
        allow(shift_item_repository).to receive(:find_by_name).with('Aferir pressão')
          .and_return(Arkham::Domain::Entities::ShiftItem.new(id: 'other-id', name: 'Aferir pressão'))
      end

      it 'raises ShiftItemAlreadyExistsError and does not create anything' do
        expect(shift_item_repository).not_to receive(:create)
        expect { use_case.execute(valid_params) }.to raise_error(Arkham::Domain::Errors::ShiftItemAlreadyExistsError)
      end
    end

    context 'when params are invalid' do
      it 'raises ApiValidationError when name is missing' do
        expect { use_case.execute(description: 'sem nome') }.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end
  end
end
