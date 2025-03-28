class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def authorize_visitor_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_visitor = Visitor.find(@decoded[:visitor_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :forbidden
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :forbidden
    end
  end

end
