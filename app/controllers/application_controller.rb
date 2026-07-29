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

  rescue_from Arkham::Domain::Errors::UserNotFoundError do |e|
    render json: { error: e.message }, status: :not_found
  end

  rescue_from Arkham::Domain::Errors::UserAlreadyExistsError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::UserInvalidError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::UserInactiveError do |e|
    render json: { error: e.message }, status: :forbidden
  end

  rescue_from Arkham::Domain::Errors::InvalidCredentialsError do |e|
    render json: { error: e.message }, status: :unauthorized
  end

  rescue_from Arkham::Domain::Errors::InvalidRefreshTokenError do |e|
    render json: { error: e.message }, status: :unauthorized
  end

  rescue_from Arkham::Domain::Errors::LastAdministratorError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def authorize_user_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
      render json: { error: 'User is inactive' }, status: :forbidden unless @current_user.active?
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
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
