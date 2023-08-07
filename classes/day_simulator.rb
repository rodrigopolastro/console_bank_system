# DAY_DURATION_IN_SECONDS = 60*60*24 => 24 hours in seconds
DAY_DURATION_IN_SECONDS = 60*5 # =>  5 minutes
PERCENTAGE_FEE_VALUE = 0.23/100

class DaySimulator
  attr_reader :system_start
  def initialize
    @system_start = Time.new
    puts "aqui #{system_start}"
    Thread.new do
      loop do
        sleep (DAY_DURATION_IN_SECONDS)
        update_accounts_in_overdraft
      end
    end
  end

  def next_day
    @system_start + DAY_DURATION_IN_SECONDS
  end

  def update_accounts_in_overdraft
    overdraft_accounts = Account.where{balance < 0}
    overdraft_accounts.each do |account|
      days_in_overdraft = account.days_in_overdraft + 1
      balance = account.balance * (1 + PERCENTAGE_FEE_VALUE) # => * 1.0023
      
      account.update(balance:, days_in_overdraft:)
    end
  end 

  def total_fee_percentage(account)
    total_fee = (1 + PERCENTAGE_FEE_VALUE) ** account.days_in_overdraft
    total_fee_percentage = (total_fee - 1) * 100
  end
end