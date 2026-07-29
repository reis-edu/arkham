module Arkham
  module UseCases
    class RefreshAccessToken
      def initialize(user_repository, refresh_token_repository, issue_token_pair = IssueTokenPair.new(refresh_token_repository))
        @user_repository = user_repository
        @refresh_token_repository = refresh_token_repository
        @issue_token_pair = issue_token_pair
      end

      def execute(refresh_token_params)
        plain_token = validate_refresh_token_params(refresh_token_params)[:refresh_token]
        token_digest = Digest::SHA256.hexdigest(plain_token)

        stored_token = @refresh_token_repository.find_by_token_digest(token_digest)
        raise Domain::Errors::InvalidRefreshTokenError, 'Invalid refresh token' unless stored_token
        raise Domain::Errors::InvalidRefreshTokenError, 'Refresh token expired or revoked' unless stored_token.valid_token?

        user = @user_repository.find_by_id(stored_token.user_id)
        raise Domain::Errors::UserNotFoundError, 'User not found' unless user
        raise Domain::Errors::UserInactiveError, 'User is inactive' unless user.active?

        @refresh_token_repository.revoke(stored_token.id)

        { user: user }.merge(@issue_token_pair.execute(user))
      end

      private

      def validate_refresh_token_params(params)
        result = Validators::Api::RefreshTokenContract.new.call(params)
        if result.errors.any?
          raise Validators::Errors::ApiValidationError.new(result.errors.to_h)
        end

        result.to_h
      end
    end
  end
end
