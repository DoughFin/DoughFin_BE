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
  end
end
