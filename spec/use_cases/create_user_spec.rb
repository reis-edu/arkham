require 'rails_helper'

RSpec.describe Arkham::UseCases::CreateUser do
  let(:user_repository) { instance_double(Arkham::Repository::ActiveRecord::UserRepository) }
  let(:use_case) { described_class.new(user_repository) }

  let(:valid_params) do
    {
      name: 'Joao Silva',
      login: 'joao.silva',
      email: 'joao@example.com',
      group: 'nursing_team'
    }
  end

  describe '#execute' do
    context 'when params are valid and login is not taken' do
      before do
        allow(user_repository).to receive(:find_by_login).with('joao.silva').and_return(nil)
        allow(user_repository).to receive(:create).and_return(SecureRandom.uuid)
      end

      it 'creates the user with the system default password and must_change_password true' do
        expect(user_repository).to receive(:create).with(
          hash_including(
            name: 'Joao Silva',
            login: 'joao.silva',
            email: 'joao@example.com',
            group: 'nursing_team',
            password: Arkham.config[:users][:default_password],
            must_change_password: true
          )
        )

        use_case.execute(valid_params)
      end

      it 'returns the created user id' do
        expect(use_case.execute(valid_params)).to be_present
      end
    end

    context 'when login already exists' do
      before do
        allow(user_repository).to receive(:find_by_login).with('joao.silva').and_return(
          Arkham::Domain::Entities::User.new(id: SecureRandom.uuid, login: 'joao.silva')
        )
      end

      it 'raises UserAlreadyExistsError' do
        expect { use_case.execute(valid_params) }.to raise_error(Arkham::Domain::Errors::UserAlreadyExistsError)
      end
    end

    context 'when the login does not follow the name.lastname pattern' do
      let(:invalid_login_params) { valid_params.merge(login: 'joaosilva') }

      it 'raises ApiValidationError' do
        expect { use_case.execute(invalid_login_params) }.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end

    context 'when the group is not one of the defined groups' do
      let(:invalid_group_params) { valid_params.merge(group: 'unknown_group') }

      it 'raises ApiValidationError' do
        expect { use_case.execute(invalid_group_params) }.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end

    context 'when required fields are missing' do
      it 'raises ApiValidationError' do
        expect { use_case.execute({}) }.to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end
  end
end
