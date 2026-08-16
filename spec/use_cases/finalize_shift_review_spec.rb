# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::FinalizeShiftReview do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:use_case) { described_class.new(shift_repository) }
  let(:shift_id) { SecureRandom.uuid }
  let(:actor_id) { SecureRandom.uuid }

  before do
    allow(shift_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when the execution has been finalized (ready for review)' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'execution_finalized') }

      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_repository).to receive(:finalize_review).and_return(shift_id)
      end

      it 'finalizes the review' do
        expect(shift_repository).to receive(:finalize_review).with(shift_id, by_id: actor_id)
        use_case.execute(shift_id, actor_id: actor_id)
      end
    end

    context 'when the shift is still open' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'open') }

      before { allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift) }

      it 'raises ShiftNotReadyForReviewError' do
        expect(shift_repository).not_to receive(:finalize_review)
        expect do
          use_case.execute(shift_id, actor_id: actor_id)
        end.to raise_error(Arkham::Domain::Errors::ShiftNotReadyForReviewError)
      end
    end

    context 'when the review has already been finalized' do
      let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id, status: 'review_finalized') }

      before { allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift) }

      it 'raises ShiftAlreadyFinalizedError' do
        expect(shift_repository).not_to receive(:finalize_review)
        expect do
          use_case.execute(shift_id, actor_id: actor_id)
        end.to raise_error(Arkham::Domain::Errors::ShiftAlreadyFinalizedError)
      end
    end

    context 'when the shift does not exist' do
      before { allow(shift_repository).to receive(:find_by_id).and_return(nil) }

      it 'raises ShiftNotFoundError' do
        expect do
          use_case.execute(shift_id, actor_id: actor_id)
        end.to raise_error(Arkham::Domain::Errors::ShiftNotFoundError)
      end
    end
  end
end
