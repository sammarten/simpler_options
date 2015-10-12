class AddUniqueConstraintToQuotes < ActiveRecord::Migration
  def up
  	execute <<-SQL
  		alter table quotes
  			add constraint security_period_time unique (security_id, period, time);
  	SQL
  end

  def down
  	execute <<-SQL
  		alter table quotes
  			drop constraint if exists security_period_time;
  	SQL
  end
end
