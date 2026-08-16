# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::ChangePassword do
  let(:user_repository) { instance_double(Arkham::Repository::ActiveRecord::UserRepository) }
  let(:use_case) { described_class.new(user_repository) }
  let(:user_id) { SecureRandom.uuid }
  let(:user) { Arkham::Domain::Entities::User.new(id: user_id, login: 'joao.silva') }

  describe '#execute' do
    context 'when the current password is correct' do
      before do
        allow(user_repository).to receive(:find_by_id).with(user_id).and_return(user)
        allow(user_repository).to receive(:verify_password).with(user_id, 'Arkham@2026').and_return(true)
        allow(user_repository).to receive(:update_password).with(user_id, 'NovaSenha123').and_return(user_id)
      end

      it 'updates the password' do
        expect(user_repository).to receive(:update_password).with(user_id, 'NovaSenha123')
        use_case.execute(user_id, current_password: 'Arkham@2026', new_password: 'NovaSenha123')
      end
    end

    context 'when the current password is incorrect' do
      before do
        allow(user_repository).to receive(:find_by_id).with(user_id).and_return(user)
        allow(user_repository).to receive(:verify_password).and_return(false)
      end

      it 'raises InvalidCredentialsError' do
        expect { use_case.execute(user_id, current_password: 'wrong', new_password: 'NovaSenha123') }
          .to raise_error(Arkham::Domain::Errors::InvalidCredentialsError)
      end
    end

    context 'when the user does not exist' do
      before do
        allow(user_repository).to receive(:find_by_id).and_return(nil)
      end

      it 'raises UserNotFoundError' do
        expect { use_case.execute(user_id, current_password: 'x', new_password: 'NovaSenha123') }
          .to raise_error(Arkham::Domain::Errors::UserNotFoundError)
      end
    end

    context 'when the new password is too short' do
      before do
        allow(user_repository).to receive(:find_by_id).with(user_id).and_return(user)
      end

      it 'raises ApiValidationError' do
        expect { use_case.execute(user_id, current_password: 'Arkham@2026', new_password: '123') }
          .to raise_error(Arkham::Validators::Errors::ApiValidationError)
      end
    end
  end
end
