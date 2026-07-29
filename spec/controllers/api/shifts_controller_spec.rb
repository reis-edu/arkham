require 'rails_helper'

RSpec.describe Api::ShiftsController, type: :controller do
  def auth_header_for(user)
    token = JsonWebToken.encode(user_id: user.id, group: user.group)
    request.headers['Authorization'] = "Bearer #{token}"
  end

  it 'rejects requests without a token' do
    get :index, format: :json
    expect(response).to have_http_status(:unauthorized)
  end

  %w[maintainer administrator nursing_leaders nursing_team].each do |group|
    context "when the actor is #{group}" do
      let(:actor) { create(:user, group: group) }

      before { auth_header_for(actor) }

      describe 'GET #index' do
        it 'lists shifts' do
          create(:shift)
          get :index, format: :json

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['shifts'].size).to eq(1)
        end
      end

      describe 'GET #show' do
        it 'shows the shift with its checklist' do
          shift = create(:shift)
          check = create(:shift_item_check, shift: shift)

          get :show, params: { id: shift.id }, format: :json

          expect(response).to have_http_status(:ok)
          body = JSON.parse(response.body)
          expect(body['id']).to eq(shift.id)
          expect(body['items'].first['id']).to eq(check.id)
        end
      end

      describe 'GET #current' do
        it 'returns the most recent shift not yet review_finalized' do
          create(:shift, :review_finalized, shift_date: Date.new(2026, 1, 1))
          current = create(:shift, shift_date: Date.new(2026, 2, 1))

          get :current, format: :json

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['id']).to eq(current.id)
        end
      end

      describe 'PUT #finalize_execution' do
        it 'finalizes the execution with an optional note' do
          shift = create(:shift)

          put :finalize_execution, params: { id: shift.id, execution_note: 'Tudo tranquilo' }, format: :json

          expect(response).to have_http_status(:ok)
          expect(shift.reload.status).to eq('execution_finalized')
          expect(shift.execution_note).to eq('Tudo tranquilo')
        end

        it 'returns unprocessable_entity when already finalized' do
          shift = create(:shift, :execution_finalized)

          put :finalize_execution, params: { id: shift.id }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      describe 'PUT #finalize_review' do
        it 'finalizes the review once the execution is finalized' do
          shift = create(:shift, :execution_finalized)

          put :finalize_review, params: { id: shift.id }, format: :json

          expect(response).to have_http_status(:ok)
          expect(shift.reload.status).to eq('review_finalized')
        end

        it 'returns unprocessable_entity when the execution is not finalized yet' do
          shift = create(:shift)

          put :finalize_review, params: { id: shift.id }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  context 'when the actor is employer' do
    let(:actor) { create(:user, group: 'employer') }

    before { auth_header_for(actor) }

    it 'forbids listing shifts' do
      get :index, format: :json
      expect(response).to have_http_status(:forbidden)
    end

    it 'forbids viewing the current shift' do
      get :current, format: :json
      expect(response).to have_http_status(:forbidden)
    end

    it 'forbids finalizing execution' do
      shift = create(:shift)
      put :finalize_execution, params: { id: shift.id }, format: :json

      expect(response).to have_http_status(:forbidden)
      expect(shift.reload.status).to eq('open')
    end
  end

  describe 'management actions (create/update/destroy/divergences)' do
    %w[maintainer administrator nursing_leaders].each do |group|
      context "when the actor is #{group}" do
        let(:actor) { create(:user, group: group) }

        before { auth_header_for(actor) }

        it 'creates a shift and materializes checks for active items' do
          create(:shift_item, active: true)

          post :create, params: { shift: { shift_date: '2026-08-01', shift_type: 'diurno' } }, format: :json

          expect(response).to have_http_status(:ok)
          shift_id = JSON.parse(response.body)['id']
          expect(ShiftItemCheck.where(shift_id: shift_id).count).to eq(1)
        end

        it 'returns unprocessable_entity for a duplicate date/type' do
          create(:shift, shift_date: Date.new(2026, 8, 1), shift_type: 'diurno')

          post :create, params: { shift: { shift_date: '2026-08-01', shift_type: 'diurno' } }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'destroys a shift' do
          shift = create(:shift)
          delete :destroy, params: { id: shift.id }, format: :json

          expect(response).to have_http_status(:ok)
          expect(Shift.exists?(shift.id)).to eq(false)
        end

        it 'returns divergences for a shift' do
          shift = create(:shift)
          divergent = create(:shift_item_check, :divergent, shift: shift)

          get :divergences, params: { id: shift.id }, format: :json

          expect(response).to have_http_status(:ok)
          ids = JSON.parse(response.body)['divergences'].map { |d| d['id'] }
          expect(ids).to eq([divergent.id])
        end
      end
    end

    context 'when the actor is nursing_team' do
      let(:actor) { create(:user, group: 'nursing_team') }

      before { auth_header_for(actor) }

      it 'forbids creating a shift' do
        post :create, params: { shift: { shift_date: '2026-08-01', shift_type: 'diurno' } }, format: :json
        expect(response).to have_http_status(:forbidden)
      end

      it 'forbids viewing divergences' do
        shift = create(:shift)
        get :divergences, params: { id: shift.id }, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
