# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::CopyLastShift do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:create_shift) { instance_double(Arkham::UseCases::CreateShift) }
  let(:use_case) { described_class.new(shift_repository, nil, shift_item_check_repository, create_shift) }
  let(:valid_params) { { shift_date: '2026-08-02', shift_type: 'noturno' } }

  describe '#execute' do
    context 'when a previous shift of the same type exists' do
      let(:previous_shift) { Arkham::Domain::Entities::Shift.new(id: 'previous-id', shift_type: 'noturno') }
      let(:previous_checks) do
        [
          Arkham::Domain::Entities::ShiftItemCheck.new(id: 'check-1', shift_item_id: 'item-1'),
          Arkham::Domain::Entities::ShiftItemCheck.new(id: 'check-2', shift_item_id: 'item-2')
        ]
      end

      before do
        allow(shift_repository).to receive(:find_last_by_type).with('noturno').and_return(previous_shift)
        allow(shift_item_check_repository).to receive(:find_all_for_shift)
          .with('previous-id').and_return(previous_checks)
        allow(create_shift).to receive(:execute).and_return('new-shift-id')
      end

      it 'delegates to CreateShift with the previous shift item ids' do
        expect(create_shift).to receive(:execute).with(
          shift_date: '2026-08-02', shift_type: 'noturno', shift_item_ids: %w[item-1 item-2]
        )
        expect(use_case.execute(valid_params)).to eq('new-shift-id')
      end
    end

    context 'when there is no previous shift of the same type' do
      before { allow(shift_repository).to receive(:find_last_by_type).with('noturno').and_return(nil) }

      it 'raises ShiftCopySourceNotFoundError and does not call CreateShift' do
        expect(create_shift).not_to receive(:execute)
        expect { use_case.execute(valid_params) }.to raise_error(Arkham::Domain::Errors::ShiftCopySourceNotFoundError)
      end
    end

    context 'when params are invalid' do
      it 'raises ApiValidationError for an unknown shift_type' do
        expect { use_case.execute(shift_date: '2026-08-02', shift_type: 'madrugada') }
          .to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end

      it 'raises ApiValidationError when shift_date is missing' do
        expect do
          use_case.execute(shift_type: 'noturno')
        end.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end
  end
end
