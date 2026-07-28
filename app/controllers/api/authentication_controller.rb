module Api
  class AuthenticationController < ApplicationController
    def initialize(repositories = {})
      @login_use_case = Arkham::Dependencies.login_use_case
      @refresh_access_token_use_case = Arkham::Dependencies.refresh_access_token_use_case
    end

    def login
      result = @login_use_case.execute(login_params)
      render json: Arkham::Presenters::LoginPresenter.new(result).to_json
    end

    def refresh
      result = @refresh_access_token_use_case.execute(refresh_token_params)
      render json: Arkham::Presenters::LoginPresenter.new(result).to_json
    end

    private

    def login_params
      params.permit(:login, :password).to_h
    end

    def refresh_token_params
      params.permit(:refresh_token).to_h
    end
  end
end
