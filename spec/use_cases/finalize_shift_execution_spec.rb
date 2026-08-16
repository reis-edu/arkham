# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::FinalizeShiftExecution do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:use_case) { described_class.new(shift_repository) }
  let(:shift_id) { SecureRandom.uuid }
  let(:actor_id) { SecureRandom.uuid }

  before do
    allow(shift_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when the shift is open' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'open') }

      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_repository).to receive(:finalize_execution).and_return(shift_id)
      end

      it 'finalizes the execution with the given note' do
        expect(shift_repository).to receive(:finalize_execution).with(
          shift_id, execution_note: 'Tudo tranquilo', by_id: actor_id
        )
        use_case.execute(shift_id, { execution_note: 'Tudo tranquilo' }, actor_id: actor_id)
      end

      it 'accepts an absent note' do
        expect(shift_repository).to receive(:finalize_execution).with(shift_id, execution_note: nil, by_id: actor_id)
        use_case.execute(shift_id, {}, actor_id: actor_id)
      end
    end

    context 'when the execution has already been finalized' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'execution_finalized') }

      before { allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift) }

      it 'raises ShiftAlreadyFinalizedError' do
        expect(shift_repository).not_to receive(:finalize_execution)
        expect do
          use_case.execute(shift_id, {}, actor_id: actor_id)
        end.to raise_error(Arkham::Domain::Errors::ShiftAlreadyFinalizedError)
      end
    end

    context 'when the shift does not exist' do
      before { allow(shift_repository).to receive(:find_by_id).and_return(nil) }

      it 'raises ShiftNotFoundError' do
        expect do
          use_case.execute(shift_id, {}, actor_id: actor_id)
        end.to raise_error(Arkham::Domain::Errors::ShiftNotFoundError)
      end
    end
  end
end
