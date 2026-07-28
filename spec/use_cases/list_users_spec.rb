require 'rails_helper'

RSpec.describe Arkham::UseCases::ListUsers do
  let(:user_repository) { instance_double(Arkham::Repository::ActiveRecord::UserRepository) }
  let(:use_case) { described_class.new(user_repository) }

  describe '#execute' do
    let(:expected_users) { [double('User'), double('User')] }

    before do
      allow(user_repository).to receive(:find_all).and_return(expected_users)
    end

    it 'returns all users' do
      expect(use_case.execute).to eq(expected_users)
    end

    it 'calls repository with filter params' do
      expect(user_repository).to receive(:find_all).with({ group: 'administrator' })
      use_case.execute({ group: 'administrator' })
    end

    it 'calls repository with empty hash when no filter params are given' do
      expect(user_repository).to receive(:find_all).with({})
      use_case.execute
    end
  end
end
