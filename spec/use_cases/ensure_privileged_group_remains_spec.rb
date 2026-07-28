require 'rails_helper'

RSpec.describe Arkham::UseCases::EnsurePrivilegedGroupRemains do
  let(:user_repository) { instance_double(Arkham::Repository::ActiveRecord::UserRepository) }
  let(:service) { described_class.new(user_repository) }
  let(:user_id) { SecureRandom.uuid }

  describe '#call' do
    context 'when the user is not currently privileged' do
      let(:user) { Arkham::Domain::Entities::User.new(id: user_id, group: 'nursing_team') }

      it 'does not check the remaining count' do
        expect(user_repository).not_to receive(:count_active_in_groups)
        service.call(user)
      end
    end

    context 'when new_group is a privileged group' do
      let(:user) { Arkham::Domain::Entities::User.new(id: user_id, group: 'administrator') }

      it 'does not check the remaining count (promotion, not demotion)' do
        expect(user_repository).not_to receive(:count_active_in_groups)
        service.call(user, new_group: 'maintainer')
      end
    end

    context 'when the user is privileged and would leave the group (no new_group, e.g. destroy/inactivate)' do
      let(:user) { Arkham::Domain::Entities::User.new(id: user_id, group: 'administrator') }

      it 'raises LastAdministratorError when no other privileged user remains active' do
        allow(user_repository).to receive(:count_active_in_groups)
          .with(%w[administrator maintainer], excluding_user_id: user_id).and_return(0)

        expect { service.call(user) }.to raise_error(Arkham::Domain::Errors::LastAdministratorError)
      end

      it 'does not raise when another privileged user remains active' do
        allow(user_repository).to receive(:count_active_in_groups)
          .with(%w[administrator maintainer], excluding_user_id: user_id).and_return(1)

        expect { service.call(user) }.not_to raise_error
      end
    end

    context 'when the user is privileged and being demoted to a non-privileged group' do
      let(:user) { Arkham::Domain::Entities::User.new(id: user_id, group: 'maintainer') }

      it 'raises LastAdministratorError when no other privileged user remains active' do
        allow(user_repository).to receive(:count_active_in_groups)
          .with(%w[administrator maintainer], excluding_user_id: user_id).and_return(0)

        expect { service.call(user, new_group: 'employer') }.to raise_error(Arkham::Domain::Errors::LastAdministratorError)
      end
    end
  end
end
