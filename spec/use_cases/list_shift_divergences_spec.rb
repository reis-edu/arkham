# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::ListShiftDivergences do
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:use_case) { described_class.new(shift_item_check_repository, shift_repository) }
  let(:shift_id) { SecureRandom.uuid }

  describe '#execute' do
    context 'when the shift exists' do
      it 'returns its divergent checks' do
        divergences = [Arkham::Domain::Entities::ShiftItemCheck.new(id: SecureRandom.uuid, review_status: 'divergent')]
        allow(shift_repository).to receive(:find_by_id)
          .with(shift_id).and_return(Arkham::Domain::Entities::Shift.new(id: shift_id))
        allow(shift_item_check_repository).to receive(:divergences_for_shift).with(shift_id).and_return(divergences)

        expect(use_case.execute(shift_id)).to eq(divergences)
      end
    end

    context 'when the shift does not exist' do
      it 'raises ShiftNotFoundError' do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(nil)

        expect { use_case.execute(shift_id) }.to raise_error(Arkham::Domain::Errors::ShiftNotFoundError)
      end
    end
  end
end
