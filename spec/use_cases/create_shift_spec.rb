# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::CreateShift do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:shift_item_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemRepository) }
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:use_case) { described_class.new(shift_repository, shift_item_repository, shift_item_check_repository) }
  let(:valid_params) { { shift_date: '2026-07-28', shift_type: 'diurno', shift_item_ids: %w[item-1 item-2] } }

  before do
    allow(shift_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when params are valid and the items exist' do
      before do
        allow(shift_item_repository).to receive(:all_exist?).with(%w[item-1 item-2]).and_return(true)
        allow(shift_repository).to receive(:create).and_return('shift-id')
        allow(shift_item_check_repository).to receive(:snapshot_for_shift)
      end

      it 'creates the shift with the given date, type and title (no item ids leak into the shift record)' do
        expect(shift_repository).to receive(:create)
          .with(shift_date: '2026-07-28', shift_type: 'diurno', title: nil)
        expect(use_case.execute(valid_params)).to eq('shift-id')
      end

      it 'creates the shift with the given title' do
        expect(shift_repository).to receive(:create)
          .with(shift_date: '2026-07-28', shift_type: 'diurno', title: 'Plantao noturno - Ala feminina')
        use_case.execute(valid_params.merge(title: 'Plantao noturno - Ala feminina'))
      end

      it 'snapshots a check for exactly the given items' do
        expect(shift_item_check_repository).to receive(:snapshot_for_shift).with('shift-id', %w[item-1 item-2])
        use_case.execute(valid_params)
      end

      it 'deduplicates repeated item ids before snapshotting' do
        expect(shift_item_check_repository).to receive(:snapshot_for_shift).with('shift-id', %w[item-1 item-2])
        use_case.execute(shift_date: '2026-07-28', shift_type: 'diurno', shift_item_ids: %w[item-1 item-2 item-1])
      end
    end

    context 'when one of the given item ids does not exist' do
      before do
        allow(shift_item_repository).to receive(:all_exist?).and_return(false)
      end

      it 'raises ShiftItemNotFoundError and does not create anything' do
        expect(shift_repository).not_to receive(:create)
        expect { use_case.execute(valid_params) }.to raise_error(Arkham::Domain::Errors::ShiftItemNotFoundError)
      end
    end

    context 'when params are invalid' do
      it 'raises ApiValidationError for an unknown shift_type' do
        expect { use_case.execute(shift_date: '2026-07-28', shift_type: 'madrugada', shift_item_ids: %w[item-1]) }
          .to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end

      it 'raises ApiValidationError when shift_item_ids is missing' do
        expect { use_case.execute(shift_date: '2026-07-28', shift_type: 'diurno') }
          .to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end

      it 'raises ApiValidationError when shift_item_ids is empty' do
        expect { use_case.execute(shift_date: '2026-07-28', shift_type: 'diurno', shift_item_ids: []) }
          .to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end
  end
end
