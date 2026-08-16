# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::Repository::ActiveRecord::RefreshTokenRepository do
  let(:repository) { described_class.new }
  let(:user) { create(:user) }

  describe '#create' do
    it 'persists the token digest and returns a RefreshToken entity' do
      entity = repository.create(user.id, 'digest123', 30.days.from_now)

      expect(entity).to be_a(Arkham::Domain::Entities::RefreshToken)
      expect(entity.user_id).to eq(user.id)
      expect(RefreshToken.find(entity.id).token_digest).to eq('digest123')
    end
  end

  describe '#find_by_token_digest' do
    let!(:refresh_token) { create(:refresh_token_record, user: user, token_digest: 'digest123') }

    it 'returns the matching entity' do
      entity = repository.find_by_token_digest('digest123')
      expect(entity.id).to eq(refresh_token.id)
    end

    it 'returns nil when there is no match' do
      expect(repository.find_by_token_digest('unknown')).to be_nil
    end
  end

  describe '#revoke' do
    let!(:refresh_token) { create(:refresh_token_record, user: user) }

    it 'sets revoked_at' do
      repository.revoke(refresh_token.id)
      expect(refresh_token.reload.revoked_at).to be_present
    end
  end
end
