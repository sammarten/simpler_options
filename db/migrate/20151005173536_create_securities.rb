class CreateSecurities < ActiveRecord::Migration
  def change
    create_table :securities do |t|
      t.string :name
      t.string :symbol
      t.references :exchange, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
