require "test_helper"

class ExpensesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect new when not logged in" do
    get new_trip_expense_url(trip_id: 1)
    assert_redirected_to login_url
  end
end
