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
end
