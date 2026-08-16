# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::UpdateShift do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:use_case) { described_class.new(shift_repository) }
  let(:shift_id) { SecureRandom.uuid }
  let(:shift) do
    Arkham::Domain::Entities::Shift.new(id: shift_id, shift_date: Date.new(2026, 7, 28), shift_type: 'diurno')
  end

  before do
    allow(shift_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when params are valid and there is no conflict' do
      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_repository).to receive(:find_by_date_and_type).and_return(nil)
        allow(shift_repository).to receive(:update).and_return(shift_id)
      end

      it 'updates the shift' do
        expect(shift_repository).to receive(:update).with(shift_id, hash_including(shift_type: 'noturno'))
        use_case.execute(shift_id, { shift_type: 'noturno' })
      end
    end

    context 'when the shift does not exist' do
      before { allow(shift_repository).to receive(:find_by_id).and_return(nil) }

      it 'raises ShiftNotFoundError' do
        expect do
          use_case.execute(shift_id, { shift_type: 'noturno' })
        end.to raise_error(Arkham::Domain::Errors::ShiftNotFoundError)
      end
    end

    context 'when another shift already exists for the resulting date and type' do
      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_repository).to receive(:find_by_date_and_type)
          .and_return(Arkham::Domain::Entities::Shift.new(id: 'other-id'))
      end

      it 'raises ShiftAlreadyExistsError' do
        expect(shift_repository).not_to receive(:update)
        expect do
          use_case.execute(shift_id, { shift_type: 'noturno' })
        end.to raise_error(Arkham::Domain::Errors::ShiftAlreadyExistsError)
      end
    end

    context 'when the conflicting shift found is the shift itself' do
      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_repository).to receive(:find_by_date_and_type).and_return(shift)
        allow(shift_repository).to receive(:update).and_return(shift_id)
      end

      it 'does not raise and proceeds with the update' do
        expect { use_case.execute(shift_id, { shift_type: 'diurno' }) }.not_to raise_error
      end
    end
  end
end
