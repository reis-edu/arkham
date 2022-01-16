# frozen_string_literal: true

module Visitors
  class AuthenticationController < ApplicationController
    before_action :authorize_visitor_request, except: :login

    def login
      @visitor = ::Visitor.find_by_email(params[:email])
      if @visitor&.authenticate(params[:password])
        token = JsonWebToken.encode(visitor_id: @visitor.id)
        time = Time.now + 24.hours.to_i
        render json: { token: token, exp: time.strftime('%m-%d-%Y %H:%M'),
                       username: @visitor.username }, status: :ok
      else
        render json: { error: 'unauthorized' }, status: :unauthorized
      end
    end

    private

    def login_params
      params.permit(:email, :password)
    end
  end
end
