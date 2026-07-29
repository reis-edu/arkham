require 'rails_helper'

RSpec.describe Arkham::UseCases::ShowShift do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:list_shift_item_checks) { instance_double(Arkham::UseCases::ListShiftItemChecks) }
  let(:use_case) { described_class.new(shift_repository, shift_item_check_repository, list_shift_item_checks) }
  let(:shift_id) { SecureRandom.uuid }
  let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id) }

  describe '#execute' do
    context 'when the shift exists' do
      it 'returns the shift and its checks' do
        checks = [Arkham::Domain::Entities::ShiftItemCheck.new(id: SecureRandom.uuid)]
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(list_shift_item_checks).to receive(:execute).with(shift_id).and_return(checks)

        expect(use_case.execute(shift_id)).to eq(shift: shift, checks: checks)
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
