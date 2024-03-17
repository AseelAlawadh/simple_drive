class ApplicationController < ActionController::API
  # before_action :authenticate_request
  before_action :authenticate_request
  attr_reader :current_user


  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JWT.decode(header, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
      @current_user = User.find(@decoded[0]['user_id'])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
end
