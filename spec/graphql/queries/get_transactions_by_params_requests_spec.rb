require "rails_helper"

RSpec.describe "Get Transaction by Params", type: :request do
  it "returns all of a user's transactions from specific month and category" do
    user = create(:user)
    user.expenses = create_list(:expense, 5)
    5.times do
      user.expenses << FactoryBot.create(:expense, user: user, category: "Groceries", date: "2024-02-" + format('%02d', rand(1..28)))
    end
    user.incomes = create_list(:income, 5)

    query =  <<~GQL
          query getTransactionsByParams($email: String!, $category: String!, $month: String!) {
            user(email: $email) {
                id
                transactions(category: $category, month: $month) {
                    id
                    amount
                    date
                    category
                    type
                }
            }
          }
      GQL

    post "/graphql", params: {query: query, variables: {email: user.email, category: "Groceries", month: "2024-02"}}

    json = JSON.parse(response.body, symbolize_names: true)
    binding.pry
    data = json[:data]

    expect(data[:user][:id]).to eq(user.id.to_s)

    data[:user][:transactions].each do |transaction|
      expect(transaction).to have_key(:id)
      expect(transaction[:id].to_i).to be_a Integer
      
      expect(transaction).to have_key(:category)
      expect(transaction[:category]).to be_a String

      expect(transaction).to have_key(:amount)
      expect(transaction[:amount]).to be_a Float

      expect(transaction).to have_key(:date)
      expect(transaction[:date]).to be_a String

      expect(transaction).to have_key(:type)
      expect(transaction[:type]).to be_a String
    end
  end
end