require "rails_helper"

RSpec.describe Mutations::DeleteBudget, type: :request do
  describe "resolve" do
    it "successfully removes a budget" do
      user = create(:user)
      create :budget, user: user, category: "Food", amount: 100
      create :budget, user: user, category: "Clothing", amount: 100
      create :budget, user: user, category: "Entertainment", amount: 100
      create :budget, user: user, category: "Transportation", amount: 100
      create :budget, user: user, category: "Health", amount: 100
      budget = Budget.last

      mutation = <<~GQL
        mutation {
          deleteBudget(input: { budgetId: #{budget.id}}) {
              code
              message
              success
              }
            }
      GQL

      expect(user.budgets.length).to eq(5)

      post "/graphql", params: {query: mutation}

      json_response = JSON.parse(response.body)
      data = json_response["data"]["deleteBudget"]

      expect(data["code"]).to eq(204)
      expect(data["message"]).to eq("Successfully deleted budget")
      expect(data["success"]).to be(true)

      expect(Budget.all.length).to eq(4)
    end
  end

  describe "sad paths" do
    it "will gracefully handle no budget found" do
      user = create(:user)
      create :budget, user: user, category: "Food", amount: 100
      create :budget, user: user, category: "Clothing", amount: 100
      create :budget, user: user, category: "Entertainment", amount: 100
      create :budget, user: user, category: "Transportation", amount: 100
      create :budget, user: user, category: "Health", amount: 100

      mutation = <<~GQL
        mutation {
          deleteBudget(input: { budgetId: 123123123 }) {
              code
              message
              success
              }
            }
      GQL

      expect(user.budgets.length).to eq(5)

      post "/graphql", params: {query: mutation}

      json_response = JSON.parse(response.body)
      data = json_response["data"]["deleteBudget"]

      expect(data["code"]).to eq(404)
      expect(data["message"]).to eq("No budget found with budgetId 123123123")
      expect(data["success"]).to be(false)

      expect(Budget.all.length).to eq(5)
    end
  end
end
