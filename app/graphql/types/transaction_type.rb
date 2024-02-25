module Types
  class TransactionType < Types::BaseObject
    field :id, ID, null: true
    field :vendor, String, null: true
    field :amount, Float, null: true
    field :date, String, null: true
    field :status, String, null: true
    field :category, String, null: true
  end
end
