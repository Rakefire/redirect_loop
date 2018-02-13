require 'test_helper'

class TestControllerTest < ActionDispatch::IntegrationTest
  test "should get loop" do
    get test_loop_url
    assert_response :success
  end

end
