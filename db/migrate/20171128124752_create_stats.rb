class CreateStats < ActiveRecord::Migration[5.1]
  def change
    create_table :stats do |t|
      t.decimal :balance, precision: 8, scale: 2
      t.decimal :profit, precision: 8, scale: 2
      t.decimal :percentage, precision: 8, scale: 4
      t.date :saved_date

      t.timestamps
    end
  end
end
