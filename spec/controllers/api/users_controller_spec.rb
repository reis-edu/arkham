require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  def auth_header_for(user)
    token = JsonWebToken.encode(user_id: user.id, group: user.group)
    request.headers['Authorization'] = "Bearer #{token}"
  end

  let(:valid_user_params) do
    { name: 'Maria Souza', login: 'maria.souza', email: 'maria@example.com', group: 'nursing_team' }
  end

  describe 'authorization guard (M1: existence, active status and token validity only)' do
    it 'rejects requests without a token' do
      post :create, params: { user: valid_user_params }, format: :json
      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects a token for a user that no longer exists' do
      ghost_id = SecureRandom.uuid
      request.headers['Authorization'] = "Bearer #{JsonWebToken.encode(user_id: ghost_id, group: 'administrator')}"

      post :create, params: { user: valid_user_params }, format: :json
      expect(response).to have_http_status(:forbidden)
    end

    it 'rejects a token for an inactive user' do
      inactive_user = create(:user, :inactive)
      auth_header_for(inactive_user)

      post :create, params: { user: valid_user_params }, format: :json
      expect(response).to have_http_status(:forbidden)
    end

    it 'accepts any active user regardless of group (no route restriction yet)' do
      basic_user = create(:user, group: 'employer')
      auth_header_for(basic_user)

      post :create, params: { user: valid_user_params }, format: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    let(:actor) { create(:user, :administrator) }

    before { auth_header_for(actor) }

    it 'creates the user with the default password and returns its id' do
      post :create, params: { user: valid_user_params }, format: :json

      expect(response).to have_http_status(:ok)
      created_id = JSON.parse(response.body)['id']

      created_user = User.find(created_id)
      expect(created_user.login).to eq('maria.souza')
      expect(created_user.must_change_password).to eq(true)
      expect(created_user.authenticate(Arkham.config[:users][:default_password])).to be_truthy
    end

    it 'returns unprocessable_entity when the login already exists' do
      create(:user, login: 'maria.souza')

      post :create, params: { user: valid_user_params }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns unprocessable_entity when required fields are missing' do
      post :create, params: { user: { name: 'Maria' } }, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PUT #change_password' do
    let(:actor) { create(:user, password: 'Arkham@2026') }

    before { auth_header_for(actor) }

    it 'updates the password and returns the user id' do
      put :change_password, params: { id: actor.id, current_password: 'Arkham@2026', new_password: 'NovaSenha123' }, format: :json

      expect(response).to have_http_status(:ok)
      expect(actor.reload.authenticate('NovaSenha123')).to be_truthy
    end

    it 'returns unauthorized when the current password is wrong' do
      put :change_password, params: { id: actor.id, current_password: 'wrong', new_password: 'NovaSenha123' }, format: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'ignores an attempt to smuggle a login change in the payload (login is immutable)' do
      original_login = actor.login

      put :change_password, params: {
        id: actor.id, current_password: 'Arkham@2026', new_password: 'NovaSenha123', login: 'hacked.login'
      }, format: :json

      expect(response).to have_http_status(:ok)
      expect(actor.reload.login).to eq(original_login)
    end

    context 'when a non-privileged user targets someone else' do
      it 'returns forbidden without touching the target password' do
        other_user = create(:user, password: 'Outra@123')

        put :change_password, params: { id: other_user.id, current_password: 'Outra@123', new_password: 'NovaSenha123' }, format: :json

        expect(response).to have_http_status(:forbidden)
        expect(other_user.reload.authenticate('Outra@123')).to be_truthy
      end
    end

    context 'when an administrator/maintainer targets someone else' do
      let(:actor) { create(:user, :administrator) }

      it 'is allowed past the ownership guard (still subject to the current password check)' do
        other_user = create(:user, password: 'Outra@123')

        put :change_password, params: { id: other_user.id, current_password: 'Outra@123', new_password: 'NovaSenha123' }, format: :json

        expect(response).to have_http_status(:ok)
        expect(other_user.reload.authenticate('NovaSenha123')).to be_truthy
      end
    end
  end

  describe 'PUT #change_group' do
    let(:actor) { create(:user, :administrator) }

    before { auth_header_for(actor) }

    context 'when another active administrator/maintainer remains' do
      before { create(:user, :maintainer) }

      it 'updates the group and returns the user id' do
        put :change_group, params: { id: actor.id, group: 'employer' }, format: :json

        expect(response).to have_http_status(:ok)
        expect(actor.reload.group).to eq('employer')
      end
    end

    context 'when the actor is the last active administrator/maintainer' do
      it 'returns unprocessable_entity and does not change the group' do
        put :change_group, params: { id: actor.id, group: 'employer' }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(actor.reload.group).to eq('administrator')
      end
    end

    context 'when the actor is not administrator/maintainer' do
      let(:actor) { create(:user, group: 'nursing_leaders') }

      it 'is forbidden from changing its own group (blocks self-escalation)' do
        put :change_group, params: { id: actor.id, group: 'administrator' }, format: :json

        expect(response).to have_http_status(:forbidden)
        expect(actor.reload.group).to eq('nursing_leaders')
      end

      it 'is forbidden from changing someone else\'s group' do
        other_user = create(:user, group: 'nursing_team')

        put :change_group, params: { id: other_user.id, group: 'nursing_leaders' }, format: :json

        expect(response).to have_http_status(:forbidden)
        expect(other_user.reload.group).to eq('nursing_team')
      end
    end
  end
end
