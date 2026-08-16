# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
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

  rescue_from Arkham::Domain::Errors::ShiftItemNotFoundError do |e|
    render json: { error: e.message }, status: :not_found
  end

  rescue_from Arkham::Domain::Errors::ShiftItemAlreadyExistsError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::ShiftItemInvalidError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::ShiftItemInUseError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::ShiftNotFoundError do |e|
    render json: { error: e.message }, status: :not_found
  end

  rescue_from Arkham::Domain::Errors::ShiftAlreadyExistsError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::ShiftInvalidError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::ShiftItemCheckNotFoundError do |e|
    render json: { error: e.message }, status: :not_found
  end

  rescue_from Arkham::Domain::Errors::ShiftItemCheckInvalidError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::ShiftItemCheckAlreadyExistsError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::ShiftAlreadyFinalizedError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::ShiftCopySourceNotFoundError do |e|
    render json: { error: e.message }, status: :not_found
  end

  rescue_from Arkham::Domain::Errors::ShiftNotReadyForReviewError do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  rescue_from Arkham::Domain::Errors::ShiftEditForbiddenError do |e|
    render json: { error: e.message }, status: :forbidden
  end

  def authorize_group!(*groups, message: 'You are not allowed to perform this action')
    return if groups.flatten.include?(@current_user.group)

    render json: { error: message }, status: :forbidden
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
# rubocop:enable Metrics/ClassLength
