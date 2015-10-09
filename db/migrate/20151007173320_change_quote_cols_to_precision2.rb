class ChangeQuoteColsToPrecision2 < ActiveRecord::Migration
  def change
  	change_column :quotes, :open, :decimal, :precision => 16, :scale =>2
  	change_column :quotes, :high, :decimal, :precision => 16, :scale =>2
  	change_column :quotes, :low, :decimal, :precision => 16, :scale =>2
  	change_column :quotes, :close, :decimal, :precision => 16, :scale =>2
  end
end
