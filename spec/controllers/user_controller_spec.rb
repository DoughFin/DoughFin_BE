require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #export" do
    before do
      User.create(username: "moneybaggins", id: 1, email: "moneybaggins@bigbanktakelilbank.doge")
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
      expected_csv = "id,email\n1,moneybaggins@bigbanktakelilbank.doge\n"
      expect(response.body).to eq(expected_csv)
    end

    it "sets the correct file name" do
      expect(response.header['Content-Disposition']).to include "users-#{Date.today}.csv"
    end
  end
end
