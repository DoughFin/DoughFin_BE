require "rails_helper"

RSpec.describe Types::CurrentExpensesType, type: :request do
  describe "resolve" do
    it "successfully gets the sum of all incomes for a user" do
      user = create(:user)
      user.expenses.create(vendor: "Current Month Vendor 1", category: "TestCategory", amount: 100.0, date: "2024-02-06")
      user.expenses.create(vendor: "Current Month Vendor 2", category: "TestCategory", amount: 100.0, date: "2024-02-06")
      user.expenses.create(vendor: "Current Month Vendor 3", category: "TestCategory", amount: 100.0, date: "2024-02-06")
      user.expenses.create(vendor: "Current Month Vendor 4", category: "TestCategory", amount: 100.0, date: "2024-02-06")
      user.expenses.create(vendor: "Current Month Vendor 5", category: "TestCategory", amount: 100.0, date: "2024-02-06")
      user.expenses.create(vendor: "Previous Month Vendor", category: "TestCategory", amount: 100.0, date: "2024-01-15")

      expect(user.expenses.length).to eq(6)

      query = <<~GQL
        query { 
          user(id: "#{user.id}") {
            currentExpenses {
              amount
              pctChange
            }
          }
        }
      GQL

      post "/graphql", params: {query: query}
      json_response = JSON.parse(response.body, symbolize_names: true)
      data = json_response[:data]

      expect(data).to have_key(:user)
      expect(data[:user]).to have_key(:currentExpenses)
      expect(data[:user][:currentExpenses]).to have_key(:amount)
      expect(data[:user][:currentExpenses][:amount]).to eq(500.0)
      expect(data[:user][:currentExpenses]).to have_key(:pctChange)
      expect(data[:user][:currentExpenses][:pctChange]).to eq(400.0)
    end
  end
end