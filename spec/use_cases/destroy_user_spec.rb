require 'rails_helper'

RSpec.describe Arkham::UseCases::DestroyUser do
  let(:user_repository) { instance_double(Arkham::Repository::ActiveRecord::UserRepository) }
  let(:ensure_privileged_group_remains) { instance_double(Arkham::UseCases::EnsurePrivilegedGroupRemains) }
  let(:use_case) { described_class.new(user_repository, ensure_privileged_group_remains) }
  let(:user_id) { SecureRandom.uuid }
  let(:user) { Arkham::Domain::Entities::User.new(id: user_id, group: 'nursing_team') }

  before do
    allow(user_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when the user exists and the safety check passes' do
      before do
        allow(user_repository).to receive(:find_by_id).with(user_id).and_return(user)
        allow(ensure_privileged_group_remains).to receive(:call).with(user)
        allow(user_repository).to receive(:destroy).with(user_id).and_return(user_id)
      end

      it 'destroys the user' do
        expect(user_repository).to receive(:destroy).with(user_id)
        use_case.execute(user_id)
      end
    end

    context 'when the user does not exist' do
      before do
        allow(user_repository).to receive(:find_by_id).and_return(nil)
      end

      it 'raises UserNotFoundError and does not destroy anything' do
        expect(user_repository).not_to receive(:destroy)
        expect { use_case.execute(user_id) }.to raise_error(Arkham::Domain::Errors::UserNotFoundError)
      end
    end

    context 'when destroying would leave no active administrator/maintainer' do
      before do
        allow(user_repository).to receive(:find_by_id).with(user_id).and_return(user)
        allow(ensure_privileged_group_remains).to receive(:call).with(user)
          .and_raise(Arkham::Domain::Errors::LastAdministratorError, 'At least one active administrator or maintainer must remain')
      end

      it 'raises LastAdministratorError and does not destroy the user' do
        expect(user_repository).not_to receive(:destroy)
        expect { use_case.execute(user_id) }.to raise_error(Arkham::Domain::Errors::LastAdministratorError)
      end
    end
  end
end
