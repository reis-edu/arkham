# frozen_string_literal: true

module Arkham
  module Presenters
    class LoginPresenter
      def initialize(login_result)
        @login_result = login_result
      end

      def to_json(*_args)
        {
          access_token: @login_result[:access_token],
          refresh_token: @login_result[:refresh_token],
          must_change_password: @login_result[:must_change_password],
          user: Arkham::Presenters::UserPresenter.new(@login_result[:user]).to_json
        }
      end
    end
  end
end
