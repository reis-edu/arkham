# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::ReviewShiftItem do
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:use_case) { described_class.new(shift_item_check_repository, shift_repository) }
  let(:shift_id) { SecureRandom.uuid }
  let(:shift_item_id) { SecureRandom.uuid }
  let(:check_id) { SecureRandom.uuid }
  let(:actor_id) { SecureRandom.uuid }
  let(:check) do
    Arkham::Domain::Entities::ShiftItemCheck.new(id: check_id, shift_id: shift_id, shift_item_id: shift_item_id)
  end

  before do
    allow(shift_item_check_repository).to receive(:within_transaction) { |&block| block.call }
    allow(shift_item_check_repository).to receive(:find_by_shift_and_item).with(shift_id,
                                                                                shift_item_id).and_return(check)
  end

  describe '#execute' do
    context 'when the shift execution has been finalized (ready for review)' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'execution_finalized') }

      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_item_check_repository).to receive(:update_review).and_return(check_id)
      end

      it 'confirms the item' do
        expect(shift_item_check_repository).to receive(:update_review).with(
          check_id, hash_including(review_status: 'confirmed', reviewed_by_id: actor_id, divergence_note: nil)
        )
        use_case.execute(shift_id, shift_item_id, { review_status: 'confirmed' }, actor_id: actor_id,
                                                                                  actor_group: 'nursing_team')
      end

      it 'registers a divergence with its note' do
        expect(shift_item_check_repository).to receive(:update_review).with(
          check_id, hash_including(review_status: 'divergent', divergence_note: 'Item não confere')
        )
        use_case.execute(
          shift_id, shift_item_id, { review_status: 'divergent', divergence_note: 'Item não confere' },
          actor_id: actor_id, actor_group: 'nursing_team'
        )
      end

      it 'raises ApiValidationError when divergent has no note' do
        expect do
          use_case.execute(shift_id, shift_item_id, { review_status: 'divergent' }, actor_id: actor_id,
                                                                                    actor_group: 'nursing_team')
        end.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end

      it 'raises ApiValidationError for an unknown review_status' do
        expect do
          use_case.execute(shift_id, shift_item_id, { review_status: 'ok' }, actor_id: actor_id,
                                                                             actor_group: 'nursing_team')
        end.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end

    context 'when the shift is still open (execution not finalized)' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'open') }

      before { allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift) }

      it 'raises ShiftNotReadyForReviewError' do
        expect(shift_item_check_repository).not_to receive(:update_review)
        expect do
          use_case.execute(shift_id, shift_item_id, { review_status: 'confirmed' }, actor_id: actor_id,
                                                                                    actor_group: 'nursing_team')
        end.to raise_error(Arkham::Domain::Errors::ShiftNotReadyForReviewError)
      end
    end

    context 'when the review has already been finalized' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'review_finalized') }

      before { allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift) }

      it 'forbids a nursing_team actor from correcting the review' do
        expect(shift_item_check_repository).not_to receive(:update_review)
        expect do
          use_case.execute(shift_id, shift_item_id, { review_status: 'confirmed' }, actor_id: actor_id,
                                                                                    actor_group: 'nursing_team')
        end.to raise_error(Arkham::Domain::Errors::ShiftEditForbiddenError)
      end

      it 'allows a nursing_leaders actor to correct the review' do
        allow(shift_item_check_repository).to receive(:update_review).and_return(check_id)
        expect(shift_item_check_repository).to receive(:update_review)
        use_case.execute(shift_id, shift_item_id, { review_status: 'confirmed' }, actor_id: actor_id,
                                                                                  actor_group: 'nursing_leaders')
      end
    end
  end
end
