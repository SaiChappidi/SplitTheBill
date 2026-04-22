require "test_helper"

class TripsControllerTest < ActionDispatch::IntegrationTest
  test "should redirect index when not logged in" do
    get trips_url
    assert_redirected_to login_url
  end

  test "should redirect new when not logged in" do
    get new_trip_url
    assert_redirected_to login_url
  end
end
