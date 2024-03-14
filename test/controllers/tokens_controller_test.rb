require 'test_helper'

class TokensControllerTest < ActionDispatch::IntegrationTest
  test "should generate token as JSON" do
    get generate_token_url(format: 'json')
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_not_nil json_response["token"]
    assert_not_nil json_response["expires_at"]
  end

  test "should generate token as QR code" do
    get generate_token_url(format: 'qr')
    assert_response :success
    assert_equal 'image/png', response.content_type
  end

  test "should return error for invalid format" do
    get generate_token_url(format: 'invalid')
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal 'Invalid format. Specify either json or qr.', json_response["error"]
  end

  test "should validate token" do
    token = Token.create(value: 'test_token', expires_at: Time.now + 1.hour)
    get validate_token_url(token: token.value)
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'Token is valid', json_response["message"]
  end

  test "should return error for invalid token" do
    get validate_token_url(token: 'invalid_token')
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal 'Invalid token', json_response["error"]
  end

  test "should delete token" do
    token = Token.create(value: 'test_token', expires_at: Time.now + 1.hour)
    delete delete_token_url(token: token.value)
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'Token deleted successfully', json_response["message"]
  end

  test "should return error for deleting non-existing token" do
    delete delete_token_url(token: 'non_existing_token')
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal 'Token not found', json_response["error"]
  end

  test "should renew token" do
    token = Token.create(value: 'test_token', expires_at: Time.now + 1.hour)
    put renew_token_url(token: token.value)
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'Token renewed successfully', json_response["message"]
    assert_not_nil json_response["expires_at"]
  end

  test "should return error for renewing expired token" do
    token = Token.create(value: 'test_token', expires_at: Time.now - 1.hour)
    put renew_token_url(token: token.value)
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal 'Token expired', json_response["error"]
  end

  test "should return error for renewing non-existing token" do
    put renew_token_url(token: 'non_existing_token')
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal 'Token not found', json_response["error"]
  end
end
