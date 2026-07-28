module Arkham
  module UseCases
    class ChangePassword
      def initialize(user_repository)
        @user_repository = user_repository
      end

      def execute(user_id, change_password_params)
        params = validate_params(change_password_params)

        user = @user_repository.find_by_id(user_id)
        raise Domain::Errors::UserNotFoundError, 'User not found' unless user

        unless @user_repository.verify_password(user_id, params[:current_password])
          raise Domain::Errors::InvalidCredentialsError, 'Current password is invalid'
        end

        @user_repository.update_password(user_id, params[:new_password])
      end

      private

      def validate_params(params)
        result = Validators::Api::ChangePasswordContract.new.call(params)
        if result.errors.any?
          raise Validators::Errors::ApiValidationError.new(result.errors.to_h)
        end

        result.to_h
      end
    end
  end
end
