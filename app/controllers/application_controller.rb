class ApplicationController < ActionController::Base
  rescue_from Arkham::Domain::Errors::PatientNotFoundError do |e|
    render json: { error: e.message }, status: :not_found
  end

  rescue_from Arkham::Domain::Errors::PatientAlreadyExistsError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::PatientInvalidError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::PatientPhotoError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Validators::Errors::ApiValidationError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

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
