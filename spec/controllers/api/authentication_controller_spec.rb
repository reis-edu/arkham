# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::AuthenticationController, type: :controller do
  describe 'POST #login' do
    let!(:user) { create(:user, login: 'joao.silva', password: 'Senha@123') }

    context 'when credentials are valid' do
      it 'returns an access token, a refresh token and the user data' do
        post :login, params: { login: 'joao.silva', password: 'Senha@123' }, format: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['access_token']).to be_present
        expect(json['refresh_token']).to be_present
        expect(json['user']['login']).to eq('joao.silva')
        expect(json['user']).not_to have_key('password')
      end
    end

    context 'when the password is wrong' do
      it 'returns unauthorized' do
        post :login, params: { login: 'joao.silva', password: 'wrong' }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the login does not exist' do
      it 'returns unauthorized' do
        post :login, params: { login: 'nao.existe', password: 'Senha@123' }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is inactive' do
      let!(:user) { create(:user, :inactive, login: 'joao.silva', password: 'Senha@123') }

      it 'returns forbidden' do
        post :login, params: { login: 'joao.silva', password: 'Senha@123' }, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST #refresh' do
    let!(:user) { create(:user, login: 'joao.silva', password: 'Senha@123') }

    def login_and_get_refresh_token
      post :login, params: { login: 'joao.silva', password: 'Senha@123' }, format: :json
      JSON.parse(response.body)['refresh_token']
    end

    context 'when the refresh token is valid' do
      it 'returns a new token pair' do
        refresh_token = login_and_get_refresh_token

        post :refresh, params: { refresh_token: refresh_token }, format: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['access_token']).to be_present
        expect(json['refresh_token']).to be_present
        expect(json['refresh_token']).not_to eq(refresh_token)
      end
    end

    context 'when the refresh token was already used (rotation)' do
      it 'rejects the second attempt' do
        refresh_token = login_and_get_refresh_token
        post :refresh, params: { refresh_token: refresh_token }, format: :json
        expect(response).to have_http_status(:ok)

        post :refresh, params: { refresh_token: refresh_token }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the refresh token does not exist' do
      it 'returns unauthorized' do
        post :refresh, params: { refresh_token: 'unknown-token' }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
