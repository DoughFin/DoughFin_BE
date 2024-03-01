require "rails_helper"

RSpec.describe "Get Transactions", type: :request do
  it "returns all of a user's transactions" do
    user = create(:user)
    user.expenses = create_list(:expense, 5)
    user.incomes = create_list(:income, 5)

    query = <<~GQL
      query getTransactions($userId: ID!) {
        user(id: $userId) {
          id
          transactions {
            id
            amount
            date
            status
            vendor
            category
          }
        }
      }
    GQL

    post "/graphql", params: {
      query: query,
      variables: {userId: user.id}
    }

    expect(response).to be_successful
      
    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data]

    expect(data[:user][:id]).to eq(user.id.to_s)

    data[:user][:transactions].each do |transaction|
      expect(transaction).to have_key(:id)
      expect(transaction[:id].to_i).to be_a Integer

      expect(transaction).to have_key(:vendor)
      expect(transaction[:vendor]).to be_a String

      expect(transaction).to have_key(:amount)
      expect(transaction[:amount]).to be_a Float

      expect(transaction).to have_key(:date)
      expect(transaction[:date]).to be_a String

      expect(transaction).to have_key(:status)
      expect(transaction[:status]).to be_a String

      expect(transaction).to have_key(:category)
      expect(transaction[:category]).to be_a String
    end
  end

  describe "sad paths" do
    it "must have a user" do
      query = <<~GQL
      query getTransactions($email: String!) {
        user(email: $email) {
          id
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

      post "/graphql", params: {query: query, variables: {email: "not_a_real_email@email.com"}}

      expect{post "/graphql", params: {query: query, variables: {email: "not_a_real_email@email.com"}}}
      .to perform_under(50).ms

      expect(response).to be_successful # graphql responses should always be successful, even when an error occurs
      
      json = JSON.parse(response.body, symbolize_names: true)
      errors = json[:errors]
      
      expect(errors.first).to have_key(:message)
      expect(errors.first[:message]).to eq("User not found.")
    end
  end
end
