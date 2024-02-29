require "rails_helper"

RSpec.describe User, type: :model do
  describe "relationships" do
    it { should have_many :incomes }
    it { should have_many :expenses }
    it { should have_many :budgets }
    it { should validate_presence_of :username }
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
  end

  it "creates a user_spec.rb with all attributes" do
    user = User.create(username: "moneybaggins", email: "moneybaggins@bigbanktakelilbank.doge")
    expect(user).to have_attributes(username: "moneybaggins")
    expect(user).to have_attributes(email: "moneybaggins@bigbanktakelilbank.doge")
  end

  describe "instance methods" do
    describe "#transactions" do
      it "gets incomes and expenses for a user as transactions" do
        user = create(:user)
        user.expenses = create_list(:expense, 5)
        user.incomes = create_list(:income, 5)
        transactions = JSON.parse(user.transactions.to_json, symbolize_names: true)

        transactions.each do |transaction|
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
        end
      end
    end
  end
end
