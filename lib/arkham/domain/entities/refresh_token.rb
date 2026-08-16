# frozen_string_literal: true

module Arkham
  module Domain
    module Entities
      class RefreshToken
        attr_reader :id, :user_id, :expires_at, :revoked_at

        def initialize(attributes = {})
          @id = attributes[:id]
          @user_id = attributes[:user_id]
          @expires_at = attributes[:expires_at]
          @revoked_at = attributes[:revoked_at]
        end

        def valid_token?
          expires_at > Time.current && revoked_at.nil?
        end
      end
    end
  end
end
