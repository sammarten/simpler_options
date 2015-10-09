require 'date'

HTTPI.adapter = :net_http

class EODData

  def initialize
    $LOG = Logger.new('trendytrady.log', 0, 100 * 1024 * 1024)
    $LOG.info "Starting new session..."
    puts "Establishing connection with eoddata web services..."

    # TODO - need error checking below
    @client = Savon.client(
          :wsdl => "http://ws.eoddata.com/data.asmx?WSDL",
          :open_timeout => 20,
          :read_timeout => 20,
          :log => false
        )

    if @client 
      puts "Connection established." 
    else
      puts "Error establishing connection."
    end
    
    @token = get_token # TODO - need error checking here
  end

  def exchange_list
    response = @client.call(:exchange_list,
      :message => {
        "Token" => @token
      })

    exchanges = []
    response.body[:exchange_list_response][:exchange_list_result][:exchanges][:exchange].each do |e|
      exchanges << { name: e[:@name], symbol: e[:@code] }
    end

    exchanges
  end

  def symbol_list(exchange:)
    response = @client.call(:symbol_list, 
      :message => { 
        "Token" => @token, 
        "Exchange" => exchange
       })

    # Pull out symbols from hash
    symbols = []
    response.body[:symbol_list_response][:symbol_list_result][:symbols][:symbol].each do |s|
      symbols << s[:@code]
    end

    symbols
  end

  def symbol_history_period_by_date_range(exchange:, symbol:, start_date:, end_date:, period:)
    puts "Exchange: #{exchange}"
    puts "Symbol: #{symbol}"
    puts "Start Date: #{start_date}"
    puts "End Date: #{end_date}"
    puts "Period: #{period}"

    begin
      response = @client.call(:symbol_history_period_by_date_range, 
        :message => { 
          "Token" => @token, 
          "Exchange" => exchange,
          "Symbol" => symbol,
          "StartDate" => start_date,
          "EndDate" => end_date,
          "Period" => period
         })

    rescue Timeout::Error => e
      $LOG.error "TIMEOUT ERROR encountered with #{symbol} for Period #{period} and Date Range #{start_date} to #{end_date}: #{e}"
      puts "TIMEOUT ERROR encountered with #{symbol}: #{e}"
      # TODO: Log these out to retry later
      # should probably retry a certain number of times here before moving on to next
      retry
    end

    result = response.body[:symbol_history_period_by_date_range_response][:symbol_history_period_by_date_range_result]

    if (result[:@message] == "Success")
      # kinda funky thing here
      # in rare cases where only one result is returned, [:quote] is a hash
      # if multiple results are returned, [:quote] is an Array
      if (result[:quotes][:quote].kind_of?(Array))
        puts "Results returned: #{result[:quotes][:quote].count}"
        return result[:quotes][:quote]
      elsif result[:quotes][:quote].kind_of?(Hash)
        # put Hash into an array of 1
        a = []
        a << result[:quotes][:quote]
        puts "Results returned: #{a.count}"
        return a
      end
    else
      puts "No results returned"
      return []
    end
  end

  def symbol_get(exchange:, symbol:)
    begin
      response = @client.call(:symbol_get,
        :message => { 
          "Token" => @token, 
          "Exchange" => exchange,
          "Symbol" => symbol
         })

      response.body[:symbol_get_response][:symbol_get_result][:symbol]

    rescue Timeout::Error => e
      puts "TIMEOUT ERROR encountered with #{symbol}: #{e}"
      # TODO: Log these out to retry later
      # should probably retry a certain number of times here before moving on to next
      retry
    end    
  end

private
  def get_token
    # Login
    response = @client.call(:login, :message => { "Username" => ENV['EODDATA_USERNAME'], 
                                                  "Password" => ENV['EODDATA_PASSWORD']  })

    # Reply with token
    response.body[:login_response][:login_result][:@token] # TODO - need error checking here
  end
end

