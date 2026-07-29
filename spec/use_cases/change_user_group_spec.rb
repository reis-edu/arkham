require 'rails_helper'

RSpec.describe Arkham::UseCases::ChangeUserGroup do
  let(:user_repository) { instance_double(Arkham::Repository::ActiveRecord::UserRepository) }
  let(:use_case) { described_class.new(user_repository) }
  let(:user_id) { SecureRandom.uuid }

  before do
    allow(user_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when the user is not currently administrator/maintainer' do
      let(:user) { Arkham::Domain::Entities::User.new(id: user_id, group: 'nursing_team') }

      before do
        allow(user_repository).to receive(:find_by_id).with(user_id).and_return(user)
        allow(user_repository).to receive(:update_group).with(user_id, 'nursing_leaders').and_return(user_id)
      end

      it 'updates the group without checking the privileged-group count' do
        expect(user_repository).not_to receive(:count_active_in_groups)
        use_case.execute(user_id, group: 'nursing_leaders')
      end
    end

    context 'when promoting a user to administrator/maintainer' do
      let(:user) { Arkham::Domain::Entities::User.new(id: user_id, group: 'nursing_team') }

      before do
        allow(user_repository).to receive(:find_by_id).with(user_id).and_return(user)
        allow(user_repository).to receive(:update_group).with(user_id, 'administrator').and_return(user_id)
      end

      it 'does not need to check remaining administrators' do
        expect(user_repository).not_to receive(:count_active_in_groups)
        use_case.execute(user_id, group: 'administrator')
      end
    end

    context 'when demoting the last active administrator/maintainer' do
      let(:user) { Arkham::Domain::Entities::User.new(id: user_id, group: 'administrator') }

      before do
        allow(user_repository).to receive(:find_by_id).with(user_id).and_return(user)
        allow(user_repository).to receive(:count_active_in_groups)
          .with(%w[administrator maintainer], excluding_user_id: user_id).and_return(0)
      end

      it 'raises LastAdministratorError and does not change the group' do
        expect(user_repository).not_to receive(:update_group)
        expect { use_case.execute(user_id, group: 'nursing_team') }
          .to raise_error(Arkham::Domain::Errors::LastAdministratorError)
      end
    end

    context 'when demoting an administrator while another one remains active' do
      let(:user) { Arkham::Domain::Entities::User.new(id: user_id, group: 'administrator') }

      before do
        allow(user_repository).to receive(:find_by_id).with(user_id).and_return(user)
        allow(user_repository).to receive(:count_active_in_groups)
          .with(%w[administrator maintainer], excluding_user_id: user_id).and_return(1)
        allow(user_repository).to receive(:update_group).with(user_id, 'employer').and_return(user_id)
      end

      it 'updates the group' do
        expect(user_repository).to receive(:update_group).with(user_id, 'employer')
        use_case.execute(user_id, group: 'employer')
      end
    end

    context 'when the user does not exist' do
      before do
        allow(user_repository).to receive(:find_by_id).and_return(nil)
      end

      it 'raises UserNotFoundError' do
        expect { use_case.execute(user_id, group: 'employer') }
          .to raise_error(Arkham::Domain::Errors::UserNotFoundError)
      end
    end

    context 'when the group is not one of the defined groups' do
      it 'raises ApiValidationError' do
        expect { use_case.execute(user_id, group: 'unknown_group') }
          .to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end
  end
end
