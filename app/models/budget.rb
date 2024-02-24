class Budget < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: true
  validates :category, presence: true
  validates :month, presence: true
  # Validates the uniqueness of the combination of category and month
  validates :category, uniqueness: {scope: :month, message: "and month combination must be unique"}

  before_save :downcase_category

  def pct_remaining
    if amount > 0
      ((amount_remaining / amount) * 100).round(1)
    else
      0
    end
  end

  def downcase_category
    self.category = category.downcase
  end

  def self.categories
    pluck(:category).uniq
  end

  def amount_remaining
    amount - amount_spent
  end

  private

  def amount_spent
    budget_month = self.month
    start_date = Date.parse("#{budget_month}-01")
    end_date = start_date.end_of_month
    Expense.where(category: category, date: start_date..end_date).sum(:amount)
  end
end
