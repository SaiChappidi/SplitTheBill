require "test_helper"

class TripTest < ActiveSupport::TestCase
  test "total owed by uses custom share amounts" do
    owner = User.create!(name: "Owner", email: "owner@example.com", password: "password")
    passenger = User.create!(name: "Passenger", email: "passenger@example.com", password: "password")
    trip = Trip.create!(name: "Custom Split", start_date: Date.current, end_date: Date.current, user: owner)
    trip.participants.create!(user: passenger)

    expense = trip.expenses.create!(description: "Dinner", amount: 100, date: Date.current, category: "Food", user: owner)
    expense.expense_shares.create!(user: owner, amount: 40)
    expense.expense_shares.create!(user: passenger, amount: 60)

    assert_equal 40.0, trip.total_owed_by(owner)
    assert_equal 60.0, trip.total_owed_by(passenger)
  end
end
