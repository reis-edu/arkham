require 'rails_helper'

RSpec.describe Arkham::UseCases::CheckShiftItem do
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:use_case) { described_class.new(shift_item_check_repository, shift_repository) }
  let(:shift_id) { SecureRandom.uuid }
  let(:shift_item_id) { SecureRandom.uuid }
  let(:check_id) { SecureRandom.uuid }
  let(:actor_id) { SecureRandom.uuid }
  let(:check) { Arkham::Domain::Entities::ShiftItemCheck.new(id: check_id, shift_id: shift_id, shift_item_id: shift_item_id) }

  before do
    allow(shift_item_check_repository).to receive(:within_transaction) { |&block| block.call }
    allow(shift_item_check_repository).to receive(:find_by_shift_and_item).with(shift_id, shift_item_id).and_return(check)
  end

  describe '#execute' do
    context 'when the shift is still open' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'open') }

      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_item_check_repository).to receive(:update_check).and_return(check_id)
      end

      it 'marks the item as checked by the actor, regardless of group' do
        expect(shift_item_check_repository).to receive(:update_check).with(
          check_id, hash_including(checked: true, checked_by_id: actor_id, impossible: false)
        )
        use_case.execute(shift_id, shift_item_id, { checked: true }, actor_id: actor_id, actor_group: 'nursing_team')
      end

      it 'marks the item as impossible with the given reason' do
        expect(shift_item_check_repository).to receive(:update_check).with(
          check_id, hash_including(impossible: true, impossible_reason: 'Sem material disponível', checked: false)
        )
        use_case.execute(
          shift_id, shift_item_id, { impossible: true, impossible_reason: 'Sem material disponível' },
          actor_id: actor_id, actor_group: 'nursing_team'
        )
      end

      it 'raises ApiValidationError when impossible has no reason' do
        expect do
          use_case.execute(shift_id, shift_item_id, { impossible: true }, actor_id: actor_id, actor_group: 'nursing_team')
        end.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end

      it 'raises ApiValidationError when checked and impossible are both true' do
        expect do
          use_case.execute(
            shift_id, shift_item_id, { checked: true, impossible: true, impossible_reason: 'x' },
            actor_id: actor_id, actor_group: 'nursing_team'
          )
        end.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end

    context 'when the shift execution has already been finalized' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'execution_finalized') }

      before { allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift) }

      it 'forbids a nursing_team actor from correcting the check' do
        expect(shift_item_check_repository).not_to receive(:update_check)
        expect do
          use_case.execute(shift_id, shift_item_id, { checked: true }, actor_id: actor_id, actor_group: 'nursing_team')
        end.to raise_error(Arkham::Domain::Errors::ShiftEditForbiddenError)
      end

      it 'allows an administrator to correct the check' do
        allow(shift_item_check_repository).to receive(:update_check).and_return(check_id)
        expect(shift_item_check_repository).to receive(:update_check)
        use_case.execute(shift_id, shift_item_id, { checked: true }, actor_id: actor_id, actor_group: 'administrator')
      end
    end

    context 'when the shift does not exist' do
      before { allow(shift_repository).to receive(:find_by_id).and_return(nil) }

      it 'raises ShiftNotFoundError' do
        expect do
          use_case.execute(shift_id, shift_item_id, { checked: true }, actor_id: actor_id, actor_group: 'nursing_team')
        end.to raise_error(Arkham::Domain::Errors::ShiftNotFoundError)
      end
    end

    context 'when the check does not exist for this shift/item pair' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'open') }

      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_item_check_repository).to receive(:find_by_shift_and_item).and_return(nil)
      end

      it 'raises ShiftItemCheckNotFoundError' do
        expect do
          use_case.execute(shift_id, shift_item_id, { checked: true }, actor_id: actor_id, actor_group: 'nursing_team')
        end.to raise_error(Arkham::Domain::Errors::ShiftItemCheckNotFoundError)
      end
    end
  end
end
