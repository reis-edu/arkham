# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::Login do
  let(:user_repository) { instance_double(Arkham::Repository::ActiveRecord::UserRepository) }
  let(:issue_token_pair) { instance_double(Arkham::UseCases::IssueTokenPair) }
  let(:use_case) { described_class.new(user_repository, issue_token_pair) }

  let(:active_user) do
    Arkham::Domain::Entities::User.new(
      id: SecureRandom.uuid, login: 'joao.silva', active: true, must_change_password: false
    )
  end

  let(:inactive_user) do
    Arkham::Domain::Entities::User.new(
      id: SecureRandom.uuid, login: 'joao.silva', active: false
    )
  end

  describe '#execute' do
    context 'when credentials are valid and user is active' do
      before do
        allow(user_repository).to receive(:authenticate).with('joao.silva', 'Senha@123').and_return(active_user)
        allow(issue_token_pair).to receive(:execute).with(active_user).and_return(
          access_token: 'token', refresh_token: 'refresh', must_change_password: false
        )
      end

      it 'returns the user and the issued token pair' do
        result = use_case.execute(login: 'joao.silva', password: 'Senha@123')

        expect(result[:user]).to eq(active_user)
        expect(result[:access_token]).to eq('token')
        expect(result[:refresh_token]).to eq('refresh')
      end
    end

    context 'when credentials are invalid' do
      before do
        allow(user_repository).to receive(:authenticate).and_return(nil)
      end

      it 'raises InvalidCredentialsError' do
        expect { use_case.execute(login: 'joao.silva', password: 'wrong') }
          .to raise_error(Arkham::Domain::Errors::InvalidCredentialsError)
      end
    end

    context 'when user is inactive' do
      before do
        allow(user_repository).to receive(:authenticate).and_return(inactive_user)
      end

      it 'raises UserInactiveError' do
        expect { use_case.execute(login: 'joao.silva', password: 'Senha@123') }
          .to raise_error(Arkham::Domain::Errors::UserInactiveError)
      end
    end

    context 'when params are missing' do
      it 'raises ApiValidationError' do
        expect { use_case.execute({}) }.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end
  end
end
