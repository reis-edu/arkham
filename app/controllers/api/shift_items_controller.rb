module Api
  class ShiftItemsController < ApplicationController
    before_action :authorize_user_request
    before_action :authorize_shift_manager

    def initialize(_ = {})
      @list_shift_items_use_case = Arkham::Dependencies.list_shift_items_use_case
      @show_shift_item_use_case = Arkham::Dependencies.show_shift_item_use_case
      @create_shift_item_use_case = Arkham::Dependencies.create_shift_item_use_case
      @update_shift_item_use_case = Arkham::Dependencies.update_shift_item_use_case
      @destroy_shift_item_use_case = Arkham::Dependencies.destroy_shift_item_use_case
    end

    def index
      shift_items = @list_shift_items_use_case.execute
      render json: Arkham::Presenters::ShiftItemListPresenter.new(shift_items).to_json
    end

    def show
      shift_item = @show_shift_item_use_case.execute(params[:id])
      render json: Arkham::Presenters::ShiftItemPresenter.new(shift_item).to_json
    end

    def create
      shift_item_params = permitted_params.to_h
      shift_item_id = @create_shift_item_use_case.execute(shift_item_params)

      render json: Arkham::Presenters::ShiftItemCreatedPresenter.new(shift_item_id).to_json
    end

    def update
      shift_item_params = permitted_params.to_h
      shift_item_id = @update_shift_item_use_case.execute(params[:id], shift_item_params)

      render json: Arkham::Presenters::ShiftItemCreatedPresenter.new(shift_item_id).to_json
    end

    def destroy
      @destroy_shift_item_use_case.execute(params[:id])

      head(:ok)
    end

    private

    def permitted_params
      params.require(:shift_item).permit!
    end

    def authorize_shift_manager
      authorize_group!(User::SHIFT_MANAGER_GROUPS)
    end
  end
end
