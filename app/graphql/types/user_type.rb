module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :expenses, resolver: Resolvers::ExpensesResolver
    field :budgets, resolver: Resolvers::BudgetsResolver
    field :transactions, [Types::TransactionType], null: true
    field :username, String, null: false
    field :email, String, null: false
    field :budgetCategories, [String], resolver: Queries::BudgetCategoriesQuery, null: true
    field :current_incomes, Types::CurrentIncomesType, null: true
    field :current_expenses, Types::CurrentExpensesType, null: true
    field :cash_flows, [Types::CashFlowType], null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # def current_incomes
    #   # current_month_income = object.incomes.where("date >= ? AND date <= ?", Date.today.at_beginning_of_month, Date.today.at_end_of_month).sum(:amount)

    #   # previous_month_income = object.incomes.where("date >= ? AND date <= ?", 1.month.ago.at_beginning_of_month, 1.month.ago.at_end_of_month).sum(:amount)

    #   # pct_change = (previous_month_income.zero? ? 0 : (current_month_income - previous_month_income) / previous_month_income.to_f) * 100

    #   {
    #     amount: object.current_month_income,
    #     pctChange: object.incomes_pct_change
    #   }
    # end

    # def current_expenses
    #   # current_month_expense = object.expenses.where("date >= ? AND date <= ?", Date.today.at_beginning_of_month, Date.today.at_end_of_month).sum(:amount)

    #   # previous_month_expense = object.expenses.where("date >= ? AND date <= ?", 1.month.ago.at_beginning_of_month, 1.month.ago.at_end_of_month).sum(:amount)

    #   # pct_change = (previous_month_expense.zero? ? 0 : (current_month_expense - previous_month_expense) / previous_month_expense.to_f) * 100

    #   {
    #     amount: object.current_month_expense,
    #     pctChange: object.expenses_pct_change
    #   }
    # end
  end
end
