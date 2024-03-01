require "rails_helper"

RSpec.describe "Get Cash Flow", type: :request do
  it "returns month by month cash flow" do
    user = create(:user)
    user.expenses = create_list(:expense, 10)
    user.incomes = create_list(:income, 10)
    query = <<~GQL
      query getCashFlow($email: String!) {
        user(email: $email) {
              id
              cashFlows {
                month
                year
                totalIncome
                totalExpense
              }
        }
      }
    GQL

    post "/graphql", params: {query: query, variables: {email: user.email}}

    expect(response).to be_successful
      
    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data]

    expect(data).to have_key(:user)
    expect(data[:user]).to be_a Hash

    expect(data[:user]).to have_key(:id)
    expect(data[:user][:id].to_i).to be_a Integer

    expect(data[:user]).to have_key(:cashFlows)
    expect(data[:user][:cashFlows]).to be_a Array

    data[:user][:cashFlows].each do |cash_flow|
      expect(cash_flow).to have_key(:year)
      expect(cash_flow[:year]).to be_a Integer

      expect(cash_flow).to have_key(:month)
      expect(cash_flow[:month]).to be_a String

      expect(cash_flow).to have_key(:month)
      expect(cash_flow[:month]).to be_a String

      expect(cash_flow).to have_key(:totalIncome)
      expect(cash_flow[:totalIncome]).to be_a Float

      expect(cash_flow).to have_key(:totalExpense)
      expect(cash_flow[:totalExpense]).to be_a Float
    end
  end

  describe "sad paths" do
    it "must have a user" do
      query = <<~GQL
      query getCashFlow($email: String!) {
        user(email: $email) {
              id
              cashFlows {
                month
                year
                totalIncome
                totalExpense
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
