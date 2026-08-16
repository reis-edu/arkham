# frozen_string_literal: true

module Arkham
  module Presenters
    class UserPresenter
      def initialize(user)
        @user = user
      end

      def to_json(*_args)
        {
          id: @user.id,
          name: @user.name,
          login: @user.login,
          email: @user.email,
          group: @user.group,
          active: @user.active?,
          must_change_password: @user.must_change_password
        }
      end
    end
  end
end
