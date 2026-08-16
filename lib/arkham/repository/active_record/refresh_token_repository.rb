# frozen_string_literal: true

module Arkham
  module Repository
    module ActiveRecord
      class RefreshTokenRepository
        def create(user_id, token_digest, expires_at)
          refresh_token = ::RefreshToken.create!(
            user_id: user_id,
            token_digest: token_digest,
            expires_at: expires_at
          )
          map_to_entity(refresh_token)
        end

        def find_by_token_digest(token_digest)
          refresh_token = ::RefreshToken.find_by(token_digest: token_digest)
          return nil unless refresh_token

          map_to_entity(refresh_token)
        end

        def revoke(refresh_token_id)
          refresh_token = ::RefreshToken.find(refresh_token_id)
          refresh_token.update!(revoked_at: Time.current)
        end

        private

        def map_to_entity(refresh_token)
          Arkham::Domain::Entities::RefreshToken.new(
            id: refresh_token.id,
            user_id: refresh_token.user_id,
            expires_at: refresh_token.expires_at,
            revoked_at: refresh_token.revoked_at
          )
        end
      end
    end
  end
end
