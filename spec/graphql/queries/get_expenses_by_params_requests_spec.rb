require "rails_helper"

RSpec.describe "Get Expenses by Params", type: :request do
  it "returns all of a user's expenses from specific month and category" do
    user = create(:user)
    user.expenses = create_list(:expense, 5)
    5.times do
      user.expenses << FactoryBot.create(:expense, user: user, category: "Groceries", date: "2024-02-" + format('%02d', rand(1..28)))
    end
    user.incomes = create_list(:income, 5)

    query =  <<~GQL
          query getExpensesByParams($email: String!, $category: String!, $month: String!) {
            user(email: $email) {
                id
                expenses(category: $category, month: $month) {
                    id
                    amount
                    date
                    category
                    # type
                }
            }
          }
      GQL

    post "/graphql", params: {query: query, variables: {email: user.email, category: "Groceries", month: "2024-02"}}

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
      expect(expense[:category]).to eq("Groceries")

      # expect(expense).to have_key(:type)
      # expect(expense[:type]).to be_a String
    end
  end
end