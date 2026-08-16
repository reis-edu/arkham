# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::RemoveShiftItem do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:use_case) { described_class.new(shift_repository, shift_item_check_repository) }
  let(:shift_id) { SecureRandom.uuid }
  let(:shift_item_id) { SecureRandom.uuid }
  let(:check_id) { SecureRandom.uuid }

  before do
    allow(shift_item_check_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when the shift is open and the item is part of it' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'open') }
      let(:check) { Arkham::Domain::Entities::ShiftItemCheck.new(id: check_id) }

      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_item_check_repository).to receive(:find_by_shift_and_item).with(shift_id,
                                                                                    shift_item_id).and_return(check)
        allow(shift_item_check_repository).to receive(:destroy).and_return(check_id)
      end

      it 'destroys the check' do
        expect(shift_item_check_repository).to receive(:destroy).with(check_id)
        use_case.execute(shift_id, shift_item_id)
      end
    end

    context 'when the shift does not exist' do
      before { allow(shift_repository).to receive(:find_by_id).and_return(nil) }

      it 'raises ShiftNotFoundError' do
        expect { use_case.execute(shift_id, shift_item_id) }.to raise_error(Arkham::Domain::Errors::ShiftNotFoundError)
      end
    end

    context 'when the shift is not open anymore' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'review_finalized') }

      before { allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift) }

      it 'raises ShiftAlreadyFinalizedError and does not destroy anything' do
        expect(shift_item_check_repository).not_to receive(:destroy)
        expect do
          use_case.execute(shift_id, shift_item_id)
        end.to raise_error(Arkham::Domain::Errors::ShiftAlreadyFinalizedError)
      end
    end

    context 'when the item is not part of the shift' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'open') }

      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_item_check_repository).to receive(:find_by_shift_and_item).and_return(nil)
      end

      it 'raises ShiftItemCheckNotFoundError' do
        expect do
          use_case.execute(shift_id, shift_item_id)
        end.to raise_error(Arkham::Domain::Errors::ShiftItemCheckNotFoundError)
      end
    end
  end
end
