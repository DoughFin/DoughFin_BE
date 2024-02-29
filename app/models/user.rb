require 'csv'

class User < ApplicationRecord
  has_many :expenses
  has_many :incomes
  has_many :budgets

  validates :username, presence: true
  validates :email, presence: true, uniqueness: true

  def transactions # finds all incomes and transactions for a user with type alias, orders by date descending
    User.find_by_sql("SELECT id,
                             amount,
                             source AS vendor,
                             date,
                             'income' AS category,
                             'credited' AS status FROM incomes WHERE user_id = #{id}
                      UNION
                      SELECT id,
                             amount,
                             vendor,
                             date,
                             category,
                             'debited' AS status FROM expenses WHERE user_id = #{id}
                      ORDER BY date DESC")

  end

  def cash_flows
    User.find_by_sql("SELECT 
    EXTRACT(YEAR FROM date) AS year,
    TO_CHAR(date, 'Month') AS month,
    COALESCE(SUM(CASE WHEN type = 'income' THEN amount END), 0) AS total_income,
    COALESCE(SUM(CASE WHEN type = 'expense' THEN amount END), 0) AS total_expense
    FROM (
      SELECT 'income' AS type, date, amount
        FROM incomes
        WHERE user_id = #{id}
      UNION ALL
      SELECT 'expense' AS type, date, amount
        FROM expenses
        WHERE user_id = #{id}
    ) AS transactions
    GROUP BY year, month
    ORDER BY year, month;")
    # select year and month
    # sum when type is income or type is expense with total_x as alias
    # coalesce to set values as 0 if null value found
    # subquery: select income/expense with type alias, date and amount where the user_id is equal to id
    # group by and order by year, then month
  end

  def incomes_pct_change
    current_month_income = incomes.where("date >= ? AND date <= ?", Date.today.at_beginning_of_month, Date.today.at_end_of_month).sum(:amount)
    previous_month_income = incomes.where("date >= ? AND date <= ?", 1.month.ago.at_beginning_of_month, 1.month.ago.at_end_of_month).sum(:amount)

    (previous_month_income.zero? ? 0 : (current_month_income - previous_month_income) / previous_month_income.to_f) * 100
  end

  def expenses_pct_change
    current_month_expense = expenses.where("date >= ? AND date <= ?", Date.today.at_beginning_of_month, Date.today.at_end_of_month).sum(:amount)
    previous_month_expense = expenses.where("date >= ? AND date <= ?", 1.month.ago.at_beginning_of_month, 1.month.ago.at_end_of_month).sum(:amount)

    pct_change = (previous_month_expense.zero? ? 0 : (current_month_expense - previous_month_expense) / previous_month_expense.to_f) * 100
  end

  def current_month_income
    incomes.sum(:amount)
  end

  def current_month_expense
    expenses.sum(:amount)
  end

  def current_incomes
    {
      amount: current_month_income,
      pctChange: incomes_pct_change
    }
  end

  def current_expenses
    {
      amount: current_month_expense,
      pctChange: expenses_pct_change
    }
  end

  def self.to_csv
    attributes = %w{id email}

    CSV.generate(headers:true) do |csv|
      csv << attributes
      all.find_each do |user|
        csv << attributes.map{|attr| user.send(attr)}
      end
    end
  end
end
