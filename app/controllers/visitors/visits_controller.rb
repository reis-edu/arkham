# frozen_string_literal: true

module Visitors
  class VisitsController < ApplicationController
    before_action :authorize_visitor_request

    def index
      @visits = list_visits
    end

    def show
      @visit = find_visit
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'visit not found' }, status: :not_found
    end

    def create
      visit_id = Services::Visits::Create.new(
        permitted_params.to_h.merge(visitor_id: @current_visitor.id)
      ).execute

      render json: { id: visit_id }
    rescue Errors::Visit::ConflictingVisitError
      render json: { error: 'There is already a visit at this time' }, status: :conflict
    end

    def update
      visit_id = Services::Visits::Update.new(
        params[:id],
        permitted_params.to_h
      ).execute

      render json: { id: visit_id }
    rescue Errors::Visit::ConflictingVisitError
      render json: { error: 'There is already a visit at this time' }, status: :conflict
    end

    def patients
      @patients = list_patients
    end

    def destroy
      Services::Visits::Destroy.new(params[:id]).execute

      head(:ok)
    rescue ActiveRecord::RecordNotFound
      head(:not_found)
    end

    private

    def permitted_params
      params.require(:visit).permit(
        :visitor_id, :patient_id, :canceled, :start_date, :end_date, :description
      )
    end

    def find_visit
      Services::Visits::Finder.find(params[:id])
    end

    def list_visits
      Services::Visits::Finder.find_visits({ visitor_id: @current_visitor.id })
    end

    def list_patients
      Services::Patients::Finder.resumed_list
    end
  end
end
