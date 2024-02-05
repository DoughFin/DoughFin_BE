require 'rails_helper'

RSpec.describe Mutations::CreateIncome, type: :request do
  describe "resolve" do
    it "successfully creates an income" do
      user = create(:user)

      expect(user.incomes.length).to eq(0)

      mutation = <<~GQL
        mutation {
          createIncome(input: {userId: #{user.id}, source: "Paycheck", amount: 2312.13, date: "2023-12-15"}) {
            user {
              id
            }
            source
            amount
            date
          }
        }
      GQL
    
      post '/graphql', params: { query: mutation }
      json_response = JSON.parse(response.body, symbolize_names: true)
      data = json_response[:data][:createIncome]

      refetch_user = User.find(user.id)

      expect(data).to have_key(:user)
      expect(data).to have_key(:source)
      expect(data).to have_key(:amount)
      expect(data).to have_key(:date)

      expect(data[:user]).to have_key(:id)
      expect(data[:user][:id].to_i).to eq(user.id)

      expect(data[:source]).to eq("Paycheck")
      expect(data[:amount]).to eq(2312.13)
      expect(data[:date]).to eq("2023-12-15")

      expect(Income.all.length).to eq(1)
      expect(refetch_user.incomes.length).to eq(1)
    end
  end
end