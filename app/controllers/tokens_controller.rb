class TokensController < ApplicationController
  require 'rqrcode'

  def generate
    expiration_time = Time.now + 30.seconds
    token = Token.create(value: SecureRandom.hex(10), expires_at: expiration_time)

    if params[:format] == 'json'
      render json: { token: token.value, expires_at: expiration_time }
    elsif params[:format] == 'qr'
      qr_code = RQRCode::QRCode.new(token.value)
      send_data qr_code.as_png(size: 300).to_s, type: 'image/png', disposition: 'inline'
    else
      render json: { error: 'Invalid format. Specify either json or qr.' }, status: :bad_request
    end
  end

  def validate
    token_value = params[:token]
    token = Token.find_by(value: token_value)

    if token.nil?
      render json: { error: 'Invalid token' }, status: :unprocessable_entity
    elsif token.expires_at < Time.now
      render json: { error: 'Token expired' }, status: :unprocessable_entity
    else
      render json: { message: 'Token is valid' }
    end
  end

  def delete
    token_value = params[:token]
    token = Token.find_by(value: token_value)

    if token.nil?
      render json: { error: 'Token not found' }, status: :unprocessable_entity
    else
      token.destroy
      render json: { message: 'Token deleted successfully' }
    end
  end

  def renew
    token_value = params[:token]
    token = Token.find_by(value: token_value)

    if token.nil?
      render json: { error: 'Token not found' }, status: :unprocessable_entity
    elsif token.expires_at < Time.now
      render json: { error: 'Token expired' }, status: :unprocessable_entity
    else
      new_expiration = token.expires_at + 30.seconds
      token.update(expires_at: new_expiration)
      render json: { message: 'Token renewed successfully', expires_at: new_expiration }
    end
  end
end
