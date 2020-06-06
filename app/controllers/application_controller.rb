class ApplicationController < ActionController::Base
 
  rescue_from StandardError do |error|
    render_unprocessable_entity(error.message)
  end

  private

  def render_unprocessable_entity(error_message)
    render json: { detail: error_message }, status: :unprocessable_entity
  end

end
