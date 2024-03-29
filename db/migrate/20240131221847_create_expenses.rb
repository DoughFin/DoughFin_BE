class CreateExpenses < ActiveRecord::Migration[7.1]
  def change
    create_table :expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :vendor
      t.string :category
      t.float :amount
      t.date :date

      t.timestamps
    end
  end
end
