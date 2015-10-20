class ChangeAtr14ColumnNameForQuotes < ActiveRecord::Migration
  def change
  	change_table :quotes do |t|
  		t.rename :true_range_14, :average_true_range_14
  	end
  end
end
