module Api
  class ShiftsController < ApplicationController
    before_action :authorize_user_request
    before_action :authorize_nursing, only: %i[index show current finalize_execution finalize_review]
    before_action :authorize_shift_manager, only: %i[create update destroy divergences]

    def initialize(_ = {})
      @list_shifts_use_case = Arkham::Dependencies.list_shifts_use_case
      @show_shift_use_case = Arkham::Dependencies.show_shift_use_case
      @show_current_shift_use_case = Arkham::Dependencies.show_current_shift_use_case
      @create_shift_use_case = Arkham::Dependencies.create_shift_use_case
      @update_shift_use_case = Arkham::Dependencies.update_shift_use_case
      @destroy_shift_use_case = Arkham::Dependencies.destroy_shift_use_case
      @finalize_shift_execution_use_case = Arkham::Dependencies.finalize_shift_execution_use_case
      @finalize_shift_review_use_case = Arkham::Dependencies.finalize_shift_review_use_case
      @list_shift_divergences_use_case = Arkham::Dependencies.list_shift_divergences_use_case
    end

    def index
      shifts = @list_shifts_use_case.execute
      render json: Arkham::Presenters::ShiftListPresenter.new(shifts).to_json
    end

    def show
      result = @show_shift_use_case.execute(params[:id])
      render json: shift_json(result)
    end

    def current
      result = @show_current_shift_use_case.execute
      render json: shift_json(result)
    end

    def create
      shift_params = permitted_params.to_h
      shift_id = @create_shift_use_case.execute(shift_params)

      render json: Arkham::Presenters::ShiftCreatedPresenter.new(shift_id).to_json
    end

    def update
      shift_params = permitted_params.to_h
      shift_id = @update_shift_use_case.execute(params[:id], shift_params)

      render json: Arkham::Presenters::ShiftCreatedPresenter.new(shift_id).to_json
    end

    def destroy
      @destroy_shift_use_case.execute(params[:id])

      head(:ok)
    end

    def finalize_execution
      shift_id = @finalize_shift_execution_use_case.execute(
        params[:id], finalize_execution_params, actor_id: @current_user.id
      )

      render json: Arkham::Presenters::ShiftCreatedPresenter.new(shift_id).to_json
    end

    def finalize_review
      shift_id = @finalize_shift_review_use_case.execute(params[:id], actor_id: @current_user.id)

      render json: Arkham::Presenters::ShiftCreatedPresenter.new(shift_id).to_json
    end

    def divergences
      divergences = @list_shift_divergences_use_case.execute(params[:id])
      render json: Arkham::Presenters::ShiftDivergenceListPresenter.new(divergences).to_json
    end

    private

    def shift_json(result)
      Arkham::Presenters::ShiftPresenter.new(result[:shift], result[:checks], viewer_group: @current_user.group).to_json
    end

    def permitted_params
      params.require(:shift).permit!
    end

    def finalize_execution_params
      params.permit(:execution_note).to_h
    end

    def authorize_nursing
      authorize_group!(User::NURSING_GROUPS)
    end

    def authorize_shift_manager
      authorize_group!(User::SHIFT_MANAGER_GROUPS)
    end
  end
end
