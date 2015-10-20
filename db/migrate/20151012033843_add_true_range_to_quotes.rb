class AddTrueRangeToQuotes < ActiveRecord::Migration
  def change
  	add_column :quotes, :true_range, :decimal
  end
end
