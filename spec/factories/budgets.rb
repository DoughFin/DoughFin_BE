require "faker"

FactoryBot.define do
  factory :budget do
    association :user

    month { "2024-02" }
    amount { Faker::Number.between(from: 10000, to: 100000) }
    category { "Business Incidentals" }
  end
end
