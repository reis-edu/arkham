# frozen_string_literal: true

module Visitors
  class VisitorsController < ApplicationController
    def create
      @visitor = ::Visitor.new(visitor_creator_params)
      if @visitor.save
        render json: @visitor, status: :created
      else
        render json: { error: @visitor.errors.full_messages.first },
               status: :unprocessable_entity
      end
    end

    private

    def visitor_creator_params
      params.permit(
        :firstname, :lastname, :email, :password, :password_confirmation
      )
    end
  end
end
