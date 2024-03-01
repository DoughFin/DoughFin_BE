require "rails_helper"

RSpec.describe "Get Expenses by Params", type: :request do
  it "returns all of a user's expenses from specific month and category" do
    user = create(:user)
    user.expenses = create_list(:expense, 5)
    5.times do
      user.expenses << FactoryBot.create(:expense, user: user, category: "Groceries", date: "2024-02-" + format("%02d", rand(1..28)))
    end
    user.incomes = create_list(:income, 5)

    query = <<~GQL
      query getExpensesByParams($email: String!, $category: String!, $month: String!) {
        user(email: $email) {
            id
            expenses(category: $category, month: $month) {
                id
                amount
                date
                category
            }
        }
      }
    GQL

    post "/graphql", params: {query: query, variables: {email: user.email, category: "Groceries", month: "2024-02"}}

    expect(response).to be_successful
      
    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data]

    expect(data[:user][:id]).to eq(user.id.to_s)

    data[:user][:expenses].each do |expense|
      expect(expense).to have_key(:id)
      expect(expense[:id].to_i).to be_a Integer

      expect(expense).to have_key(:amount)
      expect(expense[:amount]).to be_a Float

      expect(expense).to have_key(:date)
      expect(expense[:date]).to be_a String
      expect(expense[:date]).to include("2024-02")

      expect(expense).to have_key(:category)
      expect(expense[:category]).to be_a String
      expect(expense[:category]).to eq("groceries")

      # expect(expense).to have_key(:source)
      # expect(expense[:source]).to be_a String
    end
  end

  describe "sad paths" do
    it "must have a user" do
      query = <<~GQL
      query getExpensesByParams($email: String!, $category: String!, $month: String!) {
        user(email: $email) {
            id
            expenses(category: $category, month: $month) {
                id
                amount
                date
                category
            }
        }
      }
      GQL

      post "/graphql", params: {query: query, variables: {email: "not_a_real_email@email.com", category: "Groceries", month: "2024-02"}}

      expect{post "/graphql", params: {query: query, variables: {email: "not_a_real_email@email.com", category: "Groceries", month: "2024-02"}}}
      .to perform_under(50).ms

      expect(response).to be_successful # graphql responses should always be successful, even when an error occurs
      
      json = JSON.parse(response.body, symbolize_names: true)
      errors = json[:errors]
      
      expect(errors.first).to have_key(:message)
      expect(errors.first[:message]).to eq("User not found.")
    end
  end
end
