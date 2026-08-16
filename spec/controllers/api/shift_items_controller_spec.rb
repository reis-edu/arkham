# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ShiftItemsController, type: :controller do
  def auth_header_for(user)
    token = JsonWebToken.encode(user_id: user.id, group: user.group)
    request.headers['Authorization'] = "Bearer #{token}"
  end

  let(:valid_params) { { name: 'Aferir pressão', description: 'Checar PA do paciente' } }

  it 'rejects requests without a token' do
    get :index, format: :json
    expect(response).to have_http_status(:unauthorized)
  end

  %w[maintainer administrator nursing_leaders].each do |group|
    context "when the actor is #{group}" do
      let(:actor) { create(:user, group: group) }

      before { auth_header_for(actor) }

      describe 'GET #index' do
        it 'lists shift items' do
          create(:shift_item, name: 'Item A')

          get :index, format: :json

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['shift_items'].size).to eq(1)
        end
      end

      describe 'POST #create' do
        it 'creates the shift item' do
          post :create, params: { shift_item: valid_params }, format: :json

          expect(response).to have_http_status(:ok)
          expect(ShiftItem.exists?(name: 'Aferir pressão')).to eq(true)
        end

        it 'returns unprocessable_entity when the name already exists' do
          create(:shift_item, name: 'Aferir pressão')

          post :create, params: { shift_item: valid_params }, format: :json
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      describe 'PUT #update' do
        it 'updates the shift item' do
          shift_item = create(:shift_item, active: true)

          put :update, params: { id: shift_item.id, shift_item: { active: false } }, as: :json

          expect(response).to have_http_status(:ok)
          expect(shift_item.reload.active?).to eq(false)
        end
      end

      describe 'DELETE #destroy' do
        it 'destroys an unused shift item' do
          shift_item = create(:shift_item)

          delete :destroy, params: { id: shift_item.id }, format: :json

          expect(response).to have_http_status(:ok)
          expect(ShiftItem.exists?(shift_item.id)).to eq(false)
        end

        it 'returns unprocessable_entity when the item is already used in a shift' do
          shift_item = create(:shift_item)
          create(:shift_item_check, shift_item: shift_item)

          delete :destroy, params: { id: shift_item.id }, format: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(ShiftItem.exists?(shift_item.id)).to eq(true)
        end
      end
    end
  end

  %w[nursing_team employer].each do |group|
    context "when the actor is #{group}" do
      let(:actor) { create(:user, group: group) }

      before { auth_header_for(actor) }

      it 'forbids listing shift items' do
        get :index, format: :json
        expect(response).to have_http_status(:forbidden)
      end

      it 'forbids creating a shift item' do
        post :create, params: { shift_item: valid_params }, format: :json

        expect(response).to have_http_status(:forbidden)
        expect(ShiftItem.exists?(name: 'Aferir pressão')).to eq(false)
      end

      it 'forbids destroying a shift item' do
        shift_item = create(:shift_item)

        delete :destroy, params: { id: shift_item.id }, format: :json

        expect(response).to have_http_status(:forbidden)
        expect(ShiftItem.exists?(shift_item.id)).to eq(true)
      end
    end
  end
end
