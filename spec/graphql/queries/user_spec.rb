require "rails_helper"

RSpec.describe "Users", type: :request do
  let!(:user) { create :user }

  let(:query) do
    <<-GRAPHQL
      query fetchUser($email: String!) {
        user(email: $email) {
          id
          username
          email
        }
      }
    GRAPHQL
  end

  it "returns a user by email" do
    post "/graphql", params: {query: query, variables: {email: user.email}}

    expect{post "/graphql", params: {query: query, variables: {email: user.email}}}
      .to perform_under(200).ms

    expect(response).to be_successful
      
    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:user]

    expect(data[:id]).to eq(user.id.to_s)
    expect(data[:username]).to eq(user.username)
    expect(data[:email]).to eq(user.email)
  end

  let(:budget_categories) do
    <<-GRAPHQL
      query fetchUser($email: String!) {
        user(email: $email) {
          budgetCategories
        }
      }
    GRAPHQL
  end

  it "returns an array of valid budget categories" do
    user.budgets.create(category: "Food", month: "2024-02", amount: 1000)
    user.budgets.create(category: "rent", month: "2024-02", amount: 1000)
    post "/graphql", params: {query: budget_categories, variables: {email: user.email}}

    expect{post "/graphql", params: {query: budget_categories, variables: {email: user.email}}}
      .to perform_under(200).ms

    expect(response).to be_successful

    json = JSON.parse(response.body, symbolize_names: true)
    data = json[:data][:user]

    expect(data[:budgetCategories]).to be_an(Array)
    expect(data[:budgetCategories]).to include("food")
    expect(data[:budgetCategories]).to include("rent")
  end

  describe "sad paths" do
    it "must have a user" do
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
