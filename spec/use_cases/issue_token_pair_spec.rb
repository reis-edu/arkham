# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::IssueTokenPair do
  let(:refresh_token_repository) { instance_double(Arkham::Repository::ActiveRecord::RefreshTokenRepository) }
  let(:use_case) { described_class.new(refresh_token_repository) }
  let(:user) do
    Arkham::Domain::Entities::User.new(
      id: SecureRandom.uuid,
      name: 'Joao Silva',
      login: 'joao.silva',
      email: 'joao@example.com',
      group: 'administrator',
      active: true,
      must_change_password: true
    )
  end

  before do
    allow(refresh_token_repository).to receive(:create)
  end

  describe '#execute' do
    it 'returns a JWT access token encoding the user id and group' do
      result = use_case.execute(user)

      decoded = JsonWebToken.decode(result[:access_token])
      expect(decoded[:user_id]).to eq(user.id)
      expect(decoded[:group]).to eq(user.group)
    end

    it 'returns a plain refresh token and persists its digest' do
      result = use_case.execute(user)

      expect(refresh_token_repository).to have_received(:create) do |user_id, token_digest, expires_at|
        expect(user_id).to eq(user.id)
        expect(token_digest).to eq(Digest::SHA256.hexdigest(result[:refresh_token]))
        expect(expires_at).to be_a(ActiveSupport::TimeWithZone).or be_a(Time)
      end
    end

    it 'exposes must_change_password from the user' do
      result = use_case.execute(user)
      expect(result[:must_change_password]).to eq(true)
    end
  end
end
