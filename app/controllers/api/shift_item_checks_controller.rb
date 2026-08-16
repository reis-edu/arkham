# frozen_string_literal: true

module Api
  class ShiftItemChecksController < ApplicationController
    before_action :authorize_user_request
    before_action :authorize_nursing

    def initialize(_ = {})
      @check_shift_item_use_case = Arkham::Dependencies.check_shift_item_use_case
      @review_shift_item_use_case = Arkham::Dependencies.review_shift_item_use_case
    end

    def check
      check_id = @check_shift_item_use_case.execute(
        params[:shift_id], params[:shift_item_id], check_params,
        actor_id: @current_user.id, actor_group: @current_user.group
      )

      render json: Arkham::Presenters::ShiftItemCheckCreatedPresenter.new(check_id).to_json
    end

    def review
      check_id = @review_shift_item_use_case.execute(
        params[:shift_id], params[:shift_item_id], review_params,
        actor_id: @current_user.id, actor_group: @current_user.group
      )

      render json: Arkham::Presenters::ShiftItemCheckCreatedPresenter.new(check_id).to_json
    end

    private

    def check_params
      params.permit(:checked, :impossible, :impossible_reason).to_h
    end

    def review_params
      params.permit(:review_status, :divergence_note).to_h
    end

    def authorize_nursing
      authorize_group!(User::NURSING_GROUPS)
    end
  end
end
