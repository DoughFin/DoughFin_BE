require "rails_helper"

RSpec.describe "Get Budgets", type: :request do
  it "returns all of a user's budgets" do
    user = create(:user)
    create :budget, user: user, category: "Food", amount: 100
    create :budget, user: user, category: "Clothing", amount: 100
    create :budget, user: user, category: "Entertainment", amount: 100
    create :budget, user: user, category: "Transportation", amount: 100
    create :budget, user: user, category: "Health", amount: 100

    query = <<~GQL
        query GetBudgets($userId: ID!) {
            user(id: $userId) {
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

    post "/graphql", params: {
      query: query,
      variables: {userId: user.id}
    }

    expect{post "/graphql", params: {
      query: query,
      variables: {userId: user.id}
    }}.to perform_under(200).ms

    expect(response).to be_successful
      
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
