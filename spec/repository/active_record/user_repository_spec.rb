require 'rails_helper'

RSpec.describe Arkham::Repository::ActiveRecord::UserRepository do
  let(:repository) { described_class.new }

  describe '#create' do
    context 'when the user params fail model validation' do
      let(:invalid_params) do
        { name: 'Joao Silva', login: 'joao.silva', email: 'joao@example.com', group: 'unknown', password: 'Senha@123' }
      end

      it 'raises Arkham::Domain::Errors::UserInvalidError instead of ActiveRecord::RecordInvalid' do
        expect { repository.create(invalid_params) }.to raise_error(Arkham::Domain::Errors::UserInvalidError)
      end
    end
  end

  describe '#find_all' do
    it 'returns all users ordered by name' do
      create(:user, name: 'Zeca', login: 'zeca.silva')
      create(:user, name: 'Ana', login: 'ana.silva')

      entities = repository.find_all

      expect(entities.map(&:name)).to eq(%w[Ana Zeca])
    end

    it 'returns an empty array when there are no users' do
      expect(repository.find_all).to eq([])
    end
  end

  describe '#find_by_login' do
    let!(:user) { create(:user, login: 'joao.silva') }

    it 'returns the matching user entity' do
      entity = repository.find_by_login('joao.silva')
      expect(entity.id).to eq(user.id)
    end

    it 'returns nil when there is no match' do
      expect(repository.find_by_login('nao.existe')).to be_nil
    end
  end

  describe '#authenticate' do
    let!(:user) { create(:user, login: 'joao.silva', password: 'Senha@123') }

    it 'returns the user entity when the password is correct' do
      entity = repository.authenticate('joao.silva', 'Senha@123')
      expect(entity.id).to eq(user.id)
    end

    it 'returns nil when the password is wrong' do
      expect(repository.authenticate('joao.silva', 'wrong')).to be_nil
    end

    it 'returns nil when the login does not exist' do
      expect(repository.authenticate('nao.existe', 'Senha@123')).to be_nil
    end
  end

  describe '#verify_password' do
    let!(:user) { create(:user, password: 'Senha@123') }

    it 'returns true when the password matches' do
      expect(repository.verify_password(user.id, 'Senha@123')).to eq(true)
    end

    it 'returns false when the password does not match' do
      expect(repository.verify_password(user.id, 'wrong')).to eq(false)
    end
  end

  describe '#update_password' do
    let!(:user) { create(:user, password: 'Senha@123', must_change_password: true) }

    it 'updates the password and clears must_change_password' do
      repository.update_password(user.id, 'NovaSenha123')
      user.reload

      expect(user.authenticate('NovaSenha123')).to be_truthy
      expect(user.must_change_password).to eq(false)
    end
  end

  describe '#update_group' do
    let!(:user) { create(:user, group: 'nursing_team') }

    it 'updates the group' do
      repository.update_group(user.id, 'nursing_leaders')
      expect(user.reload.group).to eq('nursing_leaders')
    end
  end

  describe '#destroy' do
    let!(:user) { create(:user) }

    it 'removes the user record' do
      repository.destroy(user.id)
      expect(User.exists?(user.id)).to eq(false)
    end

    it 'also removes the user refresh tokens (dependent: :destroy)' do
      create(:refresh_token_record, user: user)

      repository.destroy(user.id)

      expect(RefreshToken.where(user_id: user.id)).to be_empty
    end
  end

  describe '#inactivate' do
    let!(:user) { create(:user, active: true) }

    it 'sets the user as inactive' do
      repository.inactivate(user.id)
      expect(user.reload.active?).to eq(false)
    end
  end

  describe '#count_active_in_groups' do
    before do
      create(:user, :administrator, active: true)
      create(:user, :maintainer, active: true)
      create(:user, :administrator, active: false)
      create(:user, group: 'nursing_team', active: true)
    end

    it 'counts only active users within the given groups' do
      expect(repository.count_active_in_groups(%w[administrator maintainer])).to eq(2)
    end

    it 'excludes the given user id from the count' do
      admin = create(:user, :administrator, active: true)
      count = repository.count_active_in_groups(%w[administrator maintainer], excluding_user_id: admin.id)
      expect(count).to eq(2)
    end
  end
end
