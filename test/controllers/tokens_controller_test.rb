require "test_helper"

class TokensControllerTest < ActionDispatch::IntegrationTest
  test "should get generate" do
    get tokens_generate_url
    assert_response :success
  end
end
