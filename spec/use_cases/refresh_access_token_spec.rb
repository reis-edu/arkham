require 'rails_helper'

RSpec.describe Arkham::UseCases::RefreshAccessToken do
  let(:user_repository) { instance_double(Arkham::Repository::ActiveRecord::UserRepository) }
  let(:refresh_token_repository) { instance_double(Arkham::Repository::ActiveRecord::RefreshTokenRepository) }
  let(:issue_token_pair) { instance_double(Arkham::UseCases::IssueTokenPair) }
  let(:use_case) { described_class.new(user_repository, refresh_token_repository, issue_token_pair) }

  let(:user_id) { SecureRandom.uuid }
  let(:active_user) { Arkham::Domain::Entities::User.new(id: user_id, active: true) }

  let(:valid_stored_token) do
    Arkham::Domain::Entities::RefreshToken.new(
      id: SecureRandom.uuid, user_id: user_id, expires_at: 1.day.from_now, revoked_at: nil
    )
  end

  let(:expired_stored_token) do
    Arkham::Domain::Entities::RefreshToken.new(
      id: SecureRandom.uuid, user_id: user_id, expires_at: 1.day.ago, revoked_at: nil
    )
  end

  describe '#execute' do
    context 'when the refresh token is valid and the user is active' do
      before do
        allow(refresh_token_repository).to receive(:find_by_token_digest).and_return(valid_stored_token)
        allow(refresh_token_repository).to receive(:revoke).with(valid_stored_token.id)
        allow(user_repository).to receive(:find_by_id).with(user_id).and_return(active_user)
        allow(issue_token_pair).to receive(:execute).with(active_user).and_return(
          access_token: 'new_token', refresh_token: 'new_refresh', must_change_password: false
        )
      end

      it 'revokes the used refresh token' do
        use_case.execute(refresh_token: 'plain-token')
        expect(refresh_token_repository).to have_received(:revoke).with(valid_stored_token.id)
      end

      it 'returns the user and a newly issued token pair' do
        result = use_case.execute(refresh_token: 'plain-token')

        expect(result[:user]).to eq(active_user)
        expect(result[:access_token]).to eq('new_token')
        expect(result[:refresh_token]).to eq('new_refresh')
      end
    end

    context 'when the refresh token does not exist' do
      before do
        allow(refresh_token_repository).to receive(:find_by_token_digest).and_return(nil)
      end

      it 'raises InvalidRefreshTokenError' do
        expect { use_case.execute(refresh_token: 'unknown') }
          .to raise_error(Arkham::Domain::Errors::InvalidRefreshTokenError)
      end
    end

    context 'when the refresh token is expired' do
      before do
        allow(refresh_token_repository).to receive(:find_by_token_digest).and_return(expired_stored_token)
      end

      it 'raises InvalidRefreshTokenError' do
        expect { use_case.execute(refresh_token: 'expired') }
          .to raise_error(Arkham::Domain::Errors::InvalidRefreshTokenError)
      end
    end

    context 'when the refresh token was already used (revoked)' do
      let(:revoked_stored_token) do
        Arkham::Domain::Entities::RefreshToken.new(
          id: SecureRandom.uuid, user_id: user_id, expires_at: 1.day.from_now, revoked_at: Time.current
        )
      end

      before do
        allow(refresh_token_repository).to receive(:find_by_token_digest).and_return(revoked_stored_token)
      end

      it 'raises InvalidRefreshTokenError' do
        expect { use_case.execute(refresh_token: 'reused') }
          .to raise_error(Arkham::Domain::Errors::InvalidRefreshTokenError)
      end
    end

    context 'when the user behind the token is inactive' do
      before do
        allow(refresh_token_repository).to receive(:find_by_token_digest).and_return(valid_stored_token)
        allow(user_repository).to receive(:find_by_id).and_return(Arkham::Domain::Entities::User.new(id: user_id, active: false))
      end

      it 'raises UserInactiveError' do
        expect { use_case.execute(refresh_token: 'plain-token') }
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
