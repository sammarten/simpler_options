class Quote < ActiveRecord::Base
  belongs_to :security

  def self.create_from_eod_data(quote_data:, security_id:, period:)
  	time_string, open, high, low, close, volume = quote_data.values_at(:@date_time, :@open, :@high, :@low, :@close, :@volume)
  	date = Date.strptime(time_string, "%Y-%m-%dT%T")
	time = Time.strptime(time_string, "%Y-%m-%dT%T")
  	Quote.create(time: time, date: date, period: period, open: open.to_f, high: high.to_f, low: low.to_f, close: close.to_f, volume: volume.to_i, security_id: security_id)
  end
end
