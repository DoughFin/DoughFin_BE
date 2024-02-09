require "rails_helper"

RSpec.describe "Get Budgets", type: :request do
  it "returns all of a user's budgets" do
    user = create(:user)
    user.budgets = create_list(:budget, 5)

    query = <<~GQL
        query GetBudgets($email: String!) {
            user(email: $email) {
                id
                budgets {
                    id
                    month
                    category
                    amount
                }
            }
      }
    GQL

    post "/graphql", params: {query: query, variables: {email: user.email}}

    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data]

    expect(data[:user][:id]).to eq(user.id.to_s)

    data[:user][:budgets].each do |budget|
      expect(budget).to have_key(:id)
      expect(budget[:id].to_i).to be_a Integer

      expect(budget).to have_key(:month)
      expect(budget[:month]).to be_a String

      expect(budget).to have_key(:category)
      expect(budget[:category]).to be_a String

      expect(budget).to have_key(:amount)
      expect(budget[:amount]).to be_a Float
    end
  end

  describe "sad paths" do
    it "must have a user" do
      query = <<~GQL
      query GetBudgets($email: String!) {
          user(email: $email) {
              id
              budgets {
                  id
                  month
                  category
                  amount
              }
          }
        }
      GQL

      post "/graphql", params: {query: query, variables: {email: "not_a_real_email@email.com"}}

      json = JSON.parse(response.body, symbolize_names: true)
      errors = json[:errors]
      
      expect(errors.first).to have_key(:message)
      expect(errors.first[:message]).to eq("User not found.")
    end
  end
end
