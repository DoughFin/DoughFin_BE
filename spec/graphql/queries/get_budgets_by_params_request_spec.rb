require "rails_helper"

RSpec.describe "Get Budgets by Search Parameters", type: :request do
  it "returns the user's budgets within the specified month and category" do
    user = create(:user)
    user.budgets = create_list(:budget, 1, category: "Groceries", amount: 350.00, month: "2024-02")
    user.expenses = create_list(:expense, 5)
    5.times do
      user.expenses << FactoryBot.create(:expense, user: user, category: "Groceries", amount: 25.00, date: "2024-02-" + format("%02d", rand(1..28)))
    end

    query = <<~GQL
        query GetBudgetsByParams($month: String!, $category: String!, $userId: ID!) {
          user(id: $userId) {
              id
              budgets(month: $month, category: $category) {
                  id
                  month
                  category
                  amount
                  pctRemaining
                  amountRemaining
              }
              expenses(category: $category, month: $month) {
                  id
                  amount
                  date
                  category
              }
          }
      }
    GQL

    post "/graphql", params: {query: query, variables: {
      userId: user.id,
      category: "Groceries",
      month: "2024-02"
    }}

    expect(response).to be_successful
      
    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data]

    expect(data[:user][:id]).to eq(user.id.to_s)

    # this doesn't run if there are no budgets
    data[:user][:budgets].each do |budget|
      expect(budget).to have_key(:id)
      expect(budget[:id].to_i).to be_a Integer

      expect(budget).to have_key(:month)
      expect(budget[:month]).to be_a String

      expect(budget).to have_key(:category)
      expect(budget[:category]).to be_a String
      expect(budget[:category]).to eq("groceries")

      expect(budget).to have_key(:amount)
      expect(budget[:amount]).to be_a Float

      expect(budget).to have_key(:pctRemaining)
      expect(budget[:pctRemaining]).to be_a Float

      expect(budget).to have_key(:amountRemaining)
      expect(budget[:amountRemaining]).to be_a Float
    end

    data[:user][:expenses].each do |expense|
      expect(expense).to have_key(:id)
      expect(expense[:id].to_i).to be_a Integer

      expect(expense).to have_key(:date)
      expect(expense[:date]).to be_a String
      expect(expense[:date]).to include("2024-02")

      expect(expense).to have_key(:category)
      expect(expense[:category]).to be_a String
      expect(expense[:category]).to eq("groceries")

      expect(expense).to have_key(:amount)
      expect(expense[:amount]).to be_a Float
    end
  end

  describe "sad paths" do
    it "must have a user" do
      query = <<~GQL
      query GetBudgetsByParams($month: String!, $category: String!, $email: String!) {
        user(email: $email) {
            id
            budgets(month: $month, category: $category) {
                id
                month
                category
                amount
                pctRemaining
                amountRemaining
            }
            expenses(category: $category, month: $month) {
                id
                amount
                date
                category
            }
        }
      }
    GQL

      post "/graphql", params: {query: query, variables: {
        email: "not_a_real_email@email.com",
        category: "Groceries",
        month: "2024-02"
      }}

      expect {post "/graphql", params: {query: query, variables: {
        email: "not_a_real_email@email.com",
        category: "Groceries",
        month: "2024-02"
      }}}.to perform_under(50).ms

      expect(response).to be_successful # graphql responses should always be successful, even when an error occurs
      
      json = JSON.parse(response.body, symbolize_names: true)
      errors = json[:errors]
      
      expect(errors.first).to have_key(:message)
      expect(errors.first[:message]).to eq("User not found.")
    end
  end
end
