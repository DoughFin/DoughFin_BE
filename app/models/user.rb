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
end
