class AddColumnsToQuotes < ActiveRecord::Migration
  def change
  	add_column :quotes, :pos_dm, :decimal, :precision => 16, :scale =>2
  	add_column :quotes, :neg_dm, :decimal, :precision => 16, :scale =>2
  	add_column :quotes, :true_range_14, :decimal, :precision => 16, :scale =>2
  	add_column :quotes, :pos_dm_14, :decimal, :precision => 16, :scale =>2
  	add_column :quotes, :neg_dm_14, :decimal, :precision => 16, :scale =>2
  end
end
