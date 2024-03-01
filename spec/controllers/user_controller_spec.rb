require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #export" do
    before do
      user = User.create(username: "moneybaggins", id: 1, email: "moneybaggins@bigbanktakelilbank.doge")
      user.expenses = create_list(:expense, 5)
      user.incomes = create_list(:income, 5)
      transactions = JSON.parse(user.transactions.to_json, symbolize_names: true)
      get :export
    end

    it "responds successfully with an HTTP 200 status code" do
      expect(response).to be_successful
      expect(response.status).to eq(200)
    end

    it "sends a CSV file" do
      expect(response.header['Content-Type']).to include 'text/csv'
    end

    it "contains the correct data in the CSV file" do
      expected_csv = "id,amount,vendor,date,category,status\n"
      expect(response.body).to include(expected_csv)
      expect(response.body).to include("income,credited")
    
      income_count = response.body.scan(/income/).count
      newline_count = response.body.scan("\n").count
      expect(income_count).to eq(5)
      expect(newline_count).to eq(11)
    end

    it "sets the correct file name" do
      expect(response.header['Content-Disposition']).to include "transactions-#{Date.today}.csv"
    end
  end
end
