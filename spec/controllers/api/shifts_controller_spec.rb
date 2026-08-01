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

        it 'includes the checked_by/reviewed_by name and login in each item' do
          checker = create(:user, name: 'Ana Souza', login: 'ana.souza')
          reviewer = create(:user, name: 'Bruno Lima', login: 'bruno.lima')
          shift = create(:shift)
          create(:shift_item_check, :checked, shift: shift, checked_by: checker, reviewed_by: reviewer)

          get :show, params: { id: shift.id }, format: :json

          item = JSON.parse(response.body)['items'].first
          expect(item['checked_by_name']).to eq('Ana Souza')
          expect(item['checked_by_login']).to eq('ana.souza')
          expect(item['reviewed_by_name']).to eq('Bruno Lima')
          expect(item['reviewed_by_login']).to eq('bruno.lima')
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

        it 'creates a shift and materializes checks for exactly the chosen items' do
          chosen = create(:shift_item)
          create(:shift_item) # not selected, should not be snapshotted

          post :create, params: {
            shift: { shift_date: '2026-08-01', shift_type: 'diurno', shift_item_ids: [chosen.id] }
          }, as: :json

          expect(response).to have_http_status(:ok)
          shift_id = JSON.parse(response.body)['id']
          expect(ShiftItemCheck.where(shift_id: shift_id).pluck(:shift_item_id)).to eq([chosen.id])
        end

        it 'returns unprocessable_entity when no shift_item_ids are given' do
          post :create, params: { shift: { shift_date: '2026-08-01', shift_type: 'diurno' } }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns not_found when a given shift_item_id does not exist' do
          post :create, params: {
            shift: { shift_date: '2026-08-01', shift_type: 'diurno', shift_item_ids: [SecureRandom.uuid] }
          }, as: :json

          expect(response).to have_http_status(:not_found)
        end

        it 'returns unprocessable_entity for a duplicate date/type' do
          create(:shift, shift_date: Date.new(2026, 8, 1), shift_type: 'diurno')
          item = create(:shift_item)

          post :create, params: {
            shift: { shift_date: '2026-08-01', shift_type: 'diurno', shift_item_ids: [item.id] }
          }, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'copies the items from the last shift of the same type' do
          previous = create(:shift, shift_date: Date.new(2026, 7, 1), shift_type: 'noturno')
          item = create(:shift_item)
          create(:shift_item_check, shift: previous, shift_item: item)

          post :copy_last, params: { shift: { shift_date: '2026-08-02', shift_type: 'noturno' } }, format: :json

          expect(response).to have_http_status(:ok)
          shift_id = JSON.parse(response.body)['id']
          expect(ShiftItemCheck.where(shift_id: shift_id).pluck(:shift_item_id)).to eq([item.id])
        end

        it 'returns not_found when copying and there is no previous shift of that type' do
          post :copy_last, params: { shift: { shift_date: '2026-08-02', shift_type: 'noturno' } }, format: :json
          expect(response).to have_http_status(:not_found)
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

        it 'adds an item to an open shift' do
          shift = create(:shift)
          shift_item = create(:shift_item)

          post :add_item, params: { shift_id: shift.id, shift_item_id: shift_item.id }, format: :json

          expect(response).to have_http_status(:ok)
          expect(ShiftItemCheck.exists?(shift_id: shift.id, shift_item_id: shift_item.id)).to eq(true)
        end

        it 'returns unprocessable_entity when adding an item already in the shift' do
          check = create(:shift_item_check)

          post :add_item, params: { shift_id: check.shift_id, shift_item_id: check.shift_item_id }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns unprocessable_entity when adding an item to a finalized shift' do
          shift = create(:shift, :execution_finalized)
          shift_item = create(:shift_item)

          post :add_item, params: { shift_id: shift.id, shift_item_id: shift_item.id }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'removes an item from an open shift' do
          check = create(:shift_item_check)

          delete :remove_item, params: { shift_id: check.shift_id, shift_item_id: check.shift_item_id }, format: :json

          expect(response).to have_http_status(:ok)
          expect(ShiftItemCheck.exists?(check.id)).to eq(false)
        end

        it 'returns unprocessable_entity when removing an item from a finalized shift' do
          shift = create(:shift, :execution_finalized)
          check = create(:shift_item_check, shift: shift)

          delete :remove_item, params: { shift_id: check.shift_id, shift_item_id: check.shift_item_id }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
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

      it 'forbids copying the last shift' do
        post :copy_last, params: { shift: { shift_date: '2026-08-02', shift_type: 'noturno' } }, format: :json
        expect(response).to have_http_status(:forbidden)
      end

      it 'forbids adding an item to a shift' do
        shift = create(:shift)
        shift_item = create(:shift_item)

        post :add_item, params: { shift_id: shift.id, shift_item_id: shift_item.id }, format: :json
        expect(response).to have_http_status(:forbidden)
      end

      it 'forbids removing an item from a shift' do
        check = create(:shift_item_check)

        delete :remove_item, params: { shift_id: check.shift_id, shift_item_id: check.shift_item_id }, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
