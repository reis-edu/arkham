module Api
  class UsersController < ApplicationController
    PRIVILEGED_GROUPS = %w[administrator maintainer].freeze

    before_action :authorize_user_request
    before_action :authorize_self_or_privileged, only: %i[change_password]
    before_action :authorize_privileged, only: %i[create change_group]

    def initialize(repositories = {})
      @create_user_use_case = Arkham::Dependencies.create_user_use_case
      @change_password_use_case = Arkham::Dependencies.change_password_use_case
      @change_user_group_use_case = Arkham::Dependencies.change_user_group_use_case
    end

    def create
      user_id = @create_user_use_case.execute(permitted_params)
      render json: Arkham::Presenters::UserCreatedPresenter.new(user_id).to_json
    end

    def change_password
      user_id = @change_password_use_case.execute(params[:id], change_password_params)
      render json: Arkham::Presenters::UserCreatedPresenter.new(user_id).to_json
    end

    def change_group
      user_id = @change_user_group_use_case.execute(params[:id], change_group_params)
      render json: Arkham::Presenters::UserCreatedPresenter.new(user_id).to_json
    end

    private

    def permitted_params
      params.require(:user).permit(:name, :login, :email, :group).to_h
    end

    def change_password_params
      params.permit(:current_password, :new_password).to_h
    end

    def change_group_params
      params.permit(:group).to_h
    end

    def authorize_self_or_privileged
      return if @current_user.id == params[:id]
      return if PRIVILEGED_GROUPS.include?(@current_user.group)

      render json: { error: 'You can only modify your own data' }, status: :forbidden
    end

    # Changing group is intentionally restricted to administrator/maintainer only
    # (not "self or privileged"): allowing a non-privileged user to change their
    # own group would let them grant themselves administrator/maintainer access.
    def authorize_privileged
      return if PRIVILEGED_GROUPS.include?(@current_user.group)

      render json: { error: 'Only administrator or maintainer can perform this action' }, status: :forbidden
    end
  end
end
