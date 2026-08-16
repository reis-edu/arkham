# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonitoringController, type: :controller do
  describe 'GET #show' do
    context 'when the database connection is healthy' do
      it 'returns ok for the api and the database' do
        get :show, format: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['arkham_api']).to eq('status' => 'ok', 'message' => 'We are fine!')
        expect(json['arkham_db']).to eq('status' => 'ok', 'message' => 'We are fine!')
      end
    end

    context 'when the database connection fails' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(StandardError, 'connection refused')
      end

      it 'returns ok for the api and fail for the database' do
        get :show, format: :json

        expect(response).to have_http_status(:service_unavailable)
        json = JSON.parse(response.body)

        expect(json['arkham_api']).to eq('status' => 'ok', 'message' => 'We are fine!')
        expect(json['arkham_db']).to eq('status' => 'fail', 'message' => 'connection refused')
      end
    end
  end
end
