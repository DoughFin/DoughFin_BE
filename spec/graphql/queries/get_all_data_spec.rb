require "rails_helper"

RSpec.describe "All Data", type: :request do
  describe "resolve" do
    it "successfully gets the sum of all incomes for a user" do
      user = User.create!(username: "bilbomoneybaggins", id: 3, email: "moneybaggins@bigbanktakelilbank.doge")
    # Expenses
      26.times { create :expense, user: user, date: "2024-02-" + rand(1..28).to_s }
    # Expenses past month
      26.times { create :expense, user: user, date: "2024-01-" + rand(1..28).to_s }
    # Budgets
      budgets = FactoryBot.build_list(:budget, 26, user: user, month: "2024-02", category: user.expenses.pluck(:category).sample)
      budgets.each { |budget| budget.save }
    # Incomes
      3.times { create :income, user: user, date: "2024-02-" + rand(1..28).to_s }
    # Incomes past month
      3.times { create :income, user: user, date: "2024-01-" + rand(1..28).to_s }

      query = <<~GQL
        query { 
          user(id: "#{user.id}") {
            currentIncomes {
              amount
              pctChange
            }
            currentExpenses {
              amount
              pctChange
            }
            cashFlows {
              month
              year
              totalIncome
              totalExpense
            }
            transactions {
              id
              amount
              date
              status
              vendor
            }
          }
        }
      GQL

      post "/graphql", params: {query: query}

      expect {post "/graphql", params: {query: query}}.to perform_under(50).ms

      json_response = JSON.parse(response.body, symbolize_names: true)
      data = json_response[:data]

      expect(data).to have_key(:user)
      expect(data[:user]).to have_key(:currentIncomes)
      expect(data[:user]).to have_key(:currentExpenses)
      expect(data[:user]).to have_key(:cashFlows)
      expect(data[:user]).to have_key(:transactions)
    end
  end
end