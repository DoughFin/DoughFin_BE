module Types
  class CurrentIncomesType < Types::BaseObject
    field :amount, Float, null: true
    field :pctChange, Float, null: true
  end
end
