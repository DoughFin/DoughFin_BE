require "rails_helper"

RSpec.describe Budget, type: :model do
  let(:user) { create :user }
  # subject refers to the shoulda-matchers object
  subject { create :budget, user: user, category: "Some Category", month: "2024-02" }
  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount) }
  it { should validate_presence_of(:category) }
  it { should validate_presence_of(:month) }
  it { should validate_uniqueness_of(:category).scoped_to(:month).with_message("and month combination must be unique") }

  describe "instance methods" do
    describe "#categories" do
      it "returns all unique categories" do
        user = create :user
        create :budget, user: user, category: "Food", amount: 100
        create :budget, user: user, category: "Clothing", amount: 100
        create :budget, user: user, category: "Entertainment", amount: 100
        create :budget, user: user, category: "Transportation", amount: 100
        create :budget, user: user, category: "Health", amount: 100

        user.budgets.categories

        expect(user.budgets.categories.size).to eq 5
      end
    end
  end

  describe "#pct_remaining, #amount_remaining" do
    before :each do
      @user = create :user
      @budget = create(:budget, category: "Groceries", amount: 350.00, month: "2024-02")
      @user.expenses = create_list(:expense, 5)
      5.times do
        @user.expenses << FactoryBot.create(:expense, amount: 25.00, user: @user, category: "Groceries", date: "2024-02-" + format("%02d", rand(1..28)))
      end
    end

    it "check instantiated data" do
      budget_expenses = Expense.where(category: @budget.category)
      expect(@user.expenses.length).to eq(10)
      expect(budget_expenses.length).to eq(5)
      expect(budget_expenses.sum(:amount)).to eq(125.0)
    end

    it "#pct_remaining calculates the percent remaining of that budget" do
      expect(@budget.pct_remaining).to eq(64.3)
    end

    it "#amount_remaining calculates the amount remaining of that budget" do
      expect(@budget.amount_remaining).to eq(225.0)
    end
  end
end
