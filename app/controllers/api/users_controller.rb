module Api
  class UsersController < ApplicationController
    before_action :authorize_user_request
    before_action :authorize_self_or_privileged, only: %i[change_password]
    before_action :authorize_privileged, only: %i[index create change_group destroy inactivate]
    before_action :forbid_self_target, only: %i[destroy inactivate]

    def initialize(repositories = {})
      @list_users_use_case = Arkham::Dependencies.list_users_use_case
      @create_user_use_case = Arkham::Dependencies.create_user_use_case
      @change_password_use_case = Arkham::Dependencies.change_password_use_case
      @change_user_group_use_case = Arkham::Dependencies.change_user_group_use_case
      @destroy_user_use_case = Arkham::Dependencies.destroy_user_use_case
      @inactivate_user_use_case = Arkham::Dependencies.inactivate_user_use_case
    end

    def index
      users = @list_users_use_case.execute
      render json: Arkham::Presenters::UserListPresenter.new(users).to_json
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

    def destroy
      @destroy_user_use_case.execute(params[:id])
      head(:ok)
    end

    def inactivate
      user_id = @inactivate_user_use_case.execute(params[:id])
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
      return if User::PRIVILEGED_GROUPS.include?(@current_user.group)

      render json: { error: 'You can only modify your own data' }, status: :forbidden
    end

    # Changing group is intentionally restricted to administrator/maintainer only
    # (not "self or privileged"): allowing a non-privileged user to change their
    # own group would let them grant themselves administrator/maintainer access.
    def authorize_privileged
      return if User::PRIVILEGED_GROUPS.include?(@current_user.group)

      render json: { error: 'Only administrator or maintainer can perform this action' }, status: :forbidden
    end

    # Destroying/inactivating your own account could lock you out (or, combined
    # with the last-admin check, be used to bypass it via a race). Always requires
    # a different administrator/maintainer to act.
    def forbid_self_target
      return unless @current_user.id == params[:id]

      render json: { error: 'You cannot perform this action on your own account' }, status: :forbidden
    end
  end
end
