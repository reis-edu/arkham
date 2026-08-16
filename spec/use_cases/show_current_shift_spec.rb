# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::ShowCurrentShift do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:list_shift_item_checks) { instance_double(Arkham::UseCases::ListShiftItemChecks) }
  let(:use_case) { described_class.new(shift_repository, shift_item_check_repository, list_shift_item_checks) }

  describe '#execute' do
    context 'when a current shift exists' do
      it 'returns the shift and its checks' do
        shift = Arkham::Domain::Entities::Shift.new(id: 'shift-id')
        checks = [Arkham::Domain::Entities::ShiftItemCheck.new(id: SecureRandom.uuid)]
        allow(shift_repository).to receive(:find_current).and_return(shift)
        allow(list_shift_item_checks).to receive(:execute).with('shift-id').and_return(checks)

        expect(use_case.execute).to eq(shift: shift, checks: checks)
      end
    end

    context 'when there is no shift at all' do
      it 'raises ShiftNotFoundError' do
        allow(shift_repository).to receive(:find_current).and_return(nil)

        expect { use_case.execute }.to raise_error(Arkham::Domain::Errors::ShiftNotFoundError)
      end
    end
  end
end
