# frozen_string_literal: true

module Types
  class IncomeType < Types::BaseObject
    field :id, ID, null: true
    field :user_id, ID, null: true
    field :user, Types::UserType, null: false
    field :source, String, null: true
    field :amount, Float, null: true
    field :date, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
