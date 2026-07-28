module Arkham
  module UseCases
    class CreateUser
      def initialize(user_repository)
        @user_repository = user_repository
      end

      def execute(user_params)
        new_user = validate_user_params(user_params)
        check_duplicate_login(new_user[:login])

        new_user[:password] = Arkham.config[:users][:default_password]
        new_user[:must_change_password] = true

        @user_repository.create(new_user)
      end

      private

      def validate_user_params(params)
        result = Validators::Api::UserContract.new.call(params)
        if result.errors.any?
          Rails.logger.error("Validators::Errors::ApiValidationError #{result.errors.to_h}")
          raise Validators::Errors::ApiValidationError.new(result.errors.to_h)
        end

        result.to_h
      end

      def check_duplicate_login(login)
        existing_user = @user_repository.find_by_login(login)
        if existing_user
          raise Domain::Errors::UserAlreadyExistsError, 'User with this login already exists!'
        end
      end
    end
  end
end
