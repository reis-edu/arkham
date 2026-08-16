# frozen_string_literal: true

module Arkham
  module Presenters
    class UserListPresenter
      def initialize(users)
        @users = users
      end

      def to_json(*_args)
        {
          users: @users.map { |user| UserPresenter.new(user).to_json }
        }
      end
    end
  end
end
