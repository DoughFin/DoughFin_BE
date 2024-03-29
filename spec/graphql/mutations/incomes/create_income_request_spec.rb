require "rails_helper"

RSpec.describe Mutations::CreateIncome, type: :request do
  describe "resolve" do
    it "successfully creates an income" do
      user = create(:user)

      expect(user.incomes.length).to eq(0)

      mutation = <<~GQL
        mutation {
          createIncome(input: {userId: #{user.id}, source: "Paycheck", amount: 2312.13, date: "2023-12-15"}) {
            userId
            income {
              source
              amount
              date
            }
          }
        }
      GQL

      post "/graphql", params: {query: mutation}

      expect(response).to be_successful
      
      json_response = JSON.parse(response.body, symbolize_names: true)
      data = json_response[:data][:createIncome]

      refetch_user = User.find(user.id)

      expect(data).to have_key(:userId)
      income = data[:income]
      expect(income).to have_key(:source)
      expect(income).to have_key(:amount)
      expect(income).to have_key(:date)

      expect(data[:userId]).to eq(user.id.to_s)
      data = data[:income]
      expect(data[:source]).to eq("paycheck")
      expect(data[:amount]).to eq(2312.13)
      expect(data[:date]).to eq("2023-12-15")
      expect(Income.all.length).to eq(1)
      expect(refetch_user.incomes.length).to eq(1)
    end
  end
end
