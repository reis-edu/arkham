# frozen_string_literal: true

module Arkham
  module UseCases
    class Login
      def initialize(user_repository,
                     issue_token_pair = IssueTokenPair.new(Repository::ActiveRecord::RefreshTokenRepository.new))
        @user_repository = user_repository
        @issue_token_pair = issue_token_pair
      end

      def execute(login_params)
        credentials = validate_login_params(login_params)

        user = @user_repository.authenticate(credentials[:login], credentials[:password])
        raise Domain::Errors::InvalidCredentialsError, 'Invalid login or password' unless user
        raise Domain::Errors::UserInactiveError, 'User is inactive' unless user.active?

        { user: user }.merge(@issue_token_pair.execute(user))
      end

      private

      def validate_login_params(params)
        result = Validators::Api::LoginContract.new.call(params)
        raise Validators::Errors::ApiValidationError, result.errors.to_h if result.errors.any?

        result.to_h
      end
    end
  end
end
