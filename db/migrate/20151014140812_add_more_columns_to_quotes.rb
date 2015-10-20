class AddMoreColumnsToQuotes < ActiveRecord::Migration
  def change
  	add_column :quotes, :plus_di_14, :decimal, :precision => 16, :scale =>2
  	add_column :quotes, :minus_di_14, :decimal, :precision => 16, :scale =>2
  	add_column :quotes, :dx, :decimal, :precision => 16, :scale =>2 # directional movement index
  	add_column :quotes, :adx, :decimal, :precision => 16, :scale =>2 # average directional index
  end
end
