class ChangeTrueRangeToPrecision2 < ActiveRecord::Migration
  def change
  	change_column :quotes, :true_range, :decimal, :precision => 16, :scale =>2
  end
end
