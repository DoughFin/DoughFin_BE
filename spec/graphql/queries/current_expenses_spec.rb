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

      
      expect(response).to be_successful
      
      json_response = JSON.parse(response.body, symbolize_names: true)
      data = json_response[:data]

      expect(data).to have_key(:user)
      expect(data[:user]).to have_key(:currentExpenses)
      expect(data[:user][:currentExpenses]).to have_key(:amount)
      expect(data[:user][:currentExpenses][:amount]).to eq(600.0)
      expect(data[:user][:currentExpenses]).to have_key(:pctChange)
      expect(data[:user][:currentExpenses][:pctChange]).to eq(0.0)

      expect {post "/graphql", params: {query: query}}.to perform_under(50).ms
    end
  end

  describe "sad paths" do
    it "must have a user" do
      query = <<~GQL
        query { 
          user(email: "not_a_real_email@email.com") {
            currentExpenses {
              amount
              pctChange
            }
          }
        }
      GQL

      post "/graphql", params: {query: query}

      expect(response).to be_successful # graphql responses should always be successful, even when an error occurs
      
      json = JSON.parse(response.body, symbolize_names: true)
      errors = json[:errors]
      
      expect(errors.first).to have_key(:message)
      expect(errors.first[:message]).to eq("User not found.")
    end
  end
end
