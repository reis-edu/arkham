# frozen_string_literal: true

module Arkham
  module UseCases
    class IssueTokenPair
      def initialize(refresh_token_repository)
        @refresh_token_repository = refresh_token_repository
      end

      def execute(user)
        access_token = JsonWebToken.encode(
          { user_id: user.id, group: user.group },
          access_token_expiration.from_now
        )

        refresh_token_plain = SecureRandom.hex(32)
        @refresh_token_repository.create(
          user.id,
          digest(refresh_token_plain),
          refresh_token_expiration.from_now
        )

        {
          access_token: access_token,
          refresh_token: refresh_token_plain,
          must_change_password: user.must_change_password
        }
      end

      private

      def digest(token)
        Digest::SHA256.hexdigest(token)
      end

      def access_token_expiration
        Arkham.config[:users][:access_token_expiration].to_i.seconds
      end

      def refresh_token_expiration
        Arkham.config[:users][:refresh_token_expiration].to_i.seconds
      end
    end
  end
end
