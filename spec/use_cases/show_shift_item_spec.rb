# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::ShowShiftItem do
  let(:shift_item_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemRepository) }
  let(:use_case) { described_class.new(shift_item_repository) }
  let(:shift_item_id) { SecureRandom.uuid }

  describe '#execute' do
    context 'when the shift item exists' do
      it 'returns it' do
        shift_item = Arkham::Domain::Entities::ShiftItem.new(id: shift_item_id)
        allow(shift_item_repository).to receive(:find_by_id).with(shift_item_id).and_return(shift_item)

        expect(use_case.execute(shift_item_id)).to eq(shift_item)
      end
    end

    context 'when the shift item does not exist' do
      it 'raises ShiftItemNotFoundError' do
        allow(shift_item_repository).to receive(:find_by_id).with(shift_item_id).and_return(nil)

        expect { use_case.execute(shift_item_id) }.to raise_error(Arkham::Domain::Errors::ShiftItemNotFoundError)
      end
    end
  end
end
