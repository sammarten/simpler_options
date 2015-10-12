class Security < ActiveRecord::Base
  belongs_to :exchange
  has_many :quotes

  def self.update_all_quotes(period:, exchange:)
  	eod = EODData.new

    results_count = 0
    securities_updated = 0

  	exchange_id = Exchange.select("id").where("symbol = \'#{exchange}\'").first.id
  	Security.where("exchange_id = #{exchange_id}").each do |s|
  		# Need to figure out what last_quote_date will return if 0 results
  		# start_date = s.last_quote_date || (DateTime.now - 400).strftime("%Y%m%d")
  		start_date = s.last_quote_date(period:"d") || "20131001"
  		end_date = "20151011"

  		results = eod.symbol_history_period_by_date_range(exchange:s.exchange.symbol, 
  														  symbol:s.symbol, 
  														  start_date:start_date, 
  														  end_date:end_date, 
  														  period:period)

      results_count += results.count
      securities_updated += 1 if results.count > 0

  		results.each do |r|
  			Quote.create_from_eod_data(quote_data:r, security_id:s.id, period:"d")
  		end
  	end

    puts "#{results_count} quotes created."
    puts "#{securities_updated} securities updated."
  end

  def last_quote_date(period:)
  	# What does this return if there are 0 results...doubt it is nil
  	result = self.quotes.select("date").where("period = \'#{period}\'").order("date DESC").limit(1)

  	# not obvious that i'm adding one to the date here, but leaving it for now
  	result.count == 0 ? nil : (result.first.date + 1).strftime("%Y%m%d")
  end

  def channel_percentage(length:, period:) # using closing prices only...not daily highs/lows
  	results = self.quotes.select("close").where("period = \'#{period}\'").order("date desc").limit(length).map { |r| r.close }
  	high = results.max
  	low = results.min
  	(results.first - low) / (high - low)
  end

  def keltner(length:, date: nil, period: nil)
    recent_quotes = self.quotes.where("period = \'d\'").order("date desc").limit(length)
    high_tot = recent_quotes.map { |q| q[:high] }.reduce(:+)
    low_tot = recent_quotes.map { |q| q[:low] }.reduce(:+)
    close_tot = recent_quotes.map { |q| q[:close] }.reduce(:+)
    avg = (high_tot + low_tot + close_tot) / (length * 3)

    range_tot = recent_quotes.map { |q| q[:high] - q[:low] }.reduce(:+)
    range_avg = range_tot / length
    return (avg - range_avg).to_f, (avg + range_avg).to_f 
  end

  def bollinger(length:, date: nil, for_period: nil)
    recent_quotes = self.quotes.where("period = \'d\'").order("date desc").limit(length)
    avg = recent_quotes.map { |q| q[:close] }.reduce(:+) / recent_quotes.count

                   # def sample_variance
                   #    m = self.mean
                   #    sum = self.inject(0){|accum, i| accum + (i - m) ** 2 }
                   #    return sum / (self.length - 1).to_f
                   #  end

                   #  def standard_deviation
                   #    return Math.sqrt(self.sample_variance)

    sum = recent_quotes.map { |q| q[:close] }.inject(0) { |accum, i| accum + (i - avg) ** 2 }
    sample_variance = sum / (recent_quotes.count - 1).to_f

    # std_dev = recent_quotes.map { |q| q[:close] }.standard_deviation
    std_dev = Math.sqrt(sample_variance)

    return (avg - (2 * std_dev)).to_f, (avg + (2 * std_dev)).to_f
  end

  def squeeze?(date: nil, period: nil)
    b_low, b_high = bollinger(length: 20, date: date)
    k_low, k_high = keltner(length: 10, date: date)
    return b_low > k_low && b_high < k_high
  end

  def adx

  end

  def self.layups #returns two arrays...bullish and bearish
    bull = []
    bear = []
    Security.all.each do |s|
      long_cp = s.channel_percentage(length:250, period:"d")
      short_cp = s.channel_percentage(length:20, period:"d")
      if long_cp >= 0.9 && short_cp >= 0.9
        bull << s
        puts "#{s.name} (#{s.symbol}) looks bullish"
      elsif long_cp <= 0.1 && short_cp <= 0.1
        bear << s
        puts "#{s.name} (#{s.symbol}) looks bearish"
      end
    end
    return bull, bear
  end

  def self.all_squeezes
    squeeze = []
    Security.all.each do |s|
      squeeze << s if s.squeeze?
    end
  end

  def true_range(date:)
    results = self.quotes.where("period = \'d\' AND date <= \'#{date.strftime("%Y-%m-%d")}\'").order("date desc").limit(2)
    if results.count < 2
      puts "Not enough data"
      return nil
    end

    # These come back as reference to the database rows
    # Each assignment requires a new db operation, it appears
    # TODO: find a way to store locally into array
    current = results.first
    previous = results.last

    first = current.high - current.low
    second = (current.high - previous.close).abs
    third = (current.low - previous.close).abs

    [first, second, third].max
  end

  def google_url
    "https://www.google.com/finance?q=#{self.symbol}"
  end
end

# RAILS_ENV=production rails c
