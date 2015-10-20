class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.datetime :time 
      t.date :date 
      t.string :period
      t.decimal :open
      t.decimal :high
      t.decimal :low
      t.decimal :close
      t.integer :volume, :limit => 8
      t.references :security, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :quotes, [:date, :period, :security_id]
  end
end
