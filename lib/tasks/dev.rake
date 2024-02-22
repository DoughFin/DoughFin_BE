namespace :dev do
  desc "Fill the database with sample data for development"
  task seed: :environment do
    require "factory_bot_rails"
    Expense.destroy_all
    Budget.destroy_all
    Income.destroy_all
    User.destroy_all
    include FactoryBot::Syntax::Methods

    # user = User.create!(username: "johnjakob", email: "email@email.com")
    # # Expenses
    # 26.times { create :expense, user: user, date: "2024-02-" + rand(1..28).to_s }
    # # Expenses past month
    # 26.times { create :expense, user: user, date: "2024-01-" + rand(1..28).to_s }
    # # Budgets
    # budgets = FactoryBot.build_list(:budget, 26, user: user, month: "2024-02", category: user.expenses.pluck(:category).sample)
    # budgets.each { |budget| budget.save }
    # # Incomes
    # 3.times { create :income, user: user, date: "2024-02-" + rand(1..28).to_s }
    # # Incomes past month
    # 3.times { create :income, user: user, date: "2024-01-" + rand(1..28).to_s }

    user2 = User.create!(username: "bilbomoneybaggins", id: 3, email: "moneybaggins@bigbanktakelilbank.doge")
    # Expenses
    26.times { create :expense, user: user2, date: "2024-02-" + rand(1..28).to_s }
    # Expenses past month
    26.times { create :expense, user: user2, date: "2024-01-" + rand(1..28).to_s }
    # Budgets
    budgets = FactoryBot.build_list(:budget, 26, user: user2, month: "2024-02", category: user2.expenses.pluck(:category).sample)
    budgets.each { |budget| budget.save }
    # Incomes
    3.times { create :income, user: user2, date: "2024-02-" + rand(1..28).to_s }
    # Incomes past month
    3.times { create :income, user: user2, date: "2024-01-" + rand(1..28).to_s }
  end
end
