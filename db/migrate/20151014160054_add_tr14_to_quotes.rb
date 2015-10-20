class AddTr14ToQuotes < ActiveRecord::Migration
  def change
  	add_column :quotes, :true_range_14, :decimal, :precision => 16, :scale =>2
  end
end
