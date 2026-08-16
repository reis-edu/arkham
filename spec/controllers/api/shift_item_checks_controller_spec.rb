# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ShiftItemChecksController, type: :controller do
  def auth_header_for(user)
    token = JsonWebToken.encode(user_id: user.id, group: user.group)
    request.headers['Authorization'] = "Bearer #{token}"
  end

  let(:shift) { create(:shift) }
  let(:check) { create(:shift_item_check, shift: shift) }

  it 'rejects requests without a token' do
    put :check, params: { shift_id: shift.id, shift_item_id: check.shift_item_id, checked: true }, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  describe 'PUT #check' do
    context 'when the actor is nursing_team' do
      let(:actor) { create(:user, group: 'nursing_team') }

      before { auth_header_for(actor) }

      it 'marks the item as checked' do
        put :check, params: { shift_id: shift.id, shift_item_id: check.shift_item_id, checked: true }, as: :json

        expect(response).to have_http_status(:ok)
        expect(check.reload.checked?).to eq(true)
        expect(check.checked_by_id).to eq(actor.id)
      end

      it 'returns unprocessable_entity when checked and impossible are both submitted' do
        put :check, params: {
          shift_id: shift.id, shift_item_id: check.shift_item_id,
          checked: true, impossible: true, impossible_reason: 'x'
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      context 'when the shift execution has already been finalized' do
        let(:shift) { create(:shift, :execution_finalized) }

        it 'is forbidden from correcting the check' do
          put :check, params: { shift_id: shift.id, shift_item_id: check.shift_item_id, checked: true }, as: :json
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'when the actor is administrator' do
      let(:actor) { create(:user, :administrator) }

      before { auth_header_for(actor) }

      context 'when the shift execution has already been finalized' do
        let(:shift) { create(:shift, :execution_finalized) }

        it 'is allowed to correct the check' do
          put :check, params: { shift_id: shift.id, shift_item_id: check.shift_item_id, checked: true }, as: :json
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when the actor is employer' do
      let(:actor) { create(:user, group: 'employer') }

      before { auth_header_for(actor) }

      it 'is forbidden' do
        put :check, params: { shift_id: shift.id, shift_item_id: check.shift_item_id, checked: true }, as: :json

        expect(response).to have_http_status(:forbidden)
        expect(check.reload.checked?).to eq(false)
      end
    end
  end

  describe 'PUT #review' do
    let(:shift) { create(:shift, :execution_finalized) }
    let(:actor) { create(:user, group: 'nursing_team') }

    before { auth_header_for(actor) }

    it 'confirms the item' do
      put :review, params: { shift_id: shift.id, shift_item_id: check.shift_item_id, review_status: 'confirmed' },
                   as: :json

      expect(response).to have_http_status(:ok)
      expect(check.reload.review_status).to eq('confirmed')
    end

    it 'registers a divergence with its note' do
      put :review, params: {
        shift_id: shift.id, shift_item_id: check.shift_item_id,
        review_status: 'divergent', divergence_note: 'Não confere'
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(check.reload.divergence_note).to eq('Não confere')
    end

    it 'returns unprocessable_entity when divergent has no note' do
      put :review, params: { shift_id: shift.id, shift_item_id: check.shift_item_id, review_status: 'divergent' },
                   as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context 'when the shift execution has not been finalized yet' do
      let(:shift) { create(:shift) }

      it 'returns unprocessable_entity' do
        put :review, params: { shift_id: shift.id, shift_item_id: check.shift_item_id, review_status: 'confirmed' },
                     as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
