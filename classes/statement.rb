require 'json'
require 'csv'

class Statement
  def initialize(account)
    @account = account
    Dir.mkdir("statements") unless Dir.exist?("statements")
  end

  def export_json
    #Current time formated in descending order for sorting purposes
    time = Time.new
    file_name = @account.number + '-' + time.strftime("%Y%m%d%H%M%S")
  
    account_number = @account.number
    account_name   = @account.name

    owner = @account.client
    owner_name          = owner.full_name
    owner_document_type = owner.document_type
    owner_document      = owner.document
    owner_name          = owner.full_name

    total_income  = @account.deposits_sum + @account.transfers_received_sum
    total_outcome = @account.withdrawals_sum + @account.transfers_made_sum
  
    statement_values = {
      account_number:,
      account_name:,
      owner_document_type:,
      owner_document:,
      owner_name:,
      total_income:,
      total_outcome:,
      deposits: deposits_hashes,
      withdrawals: withdrawals_hashes,
      transfers_made: transfers_made_hashes,
      transfers_received: transfers_received_hashes
    }
  
    Dir.mkdir("statements/json") unless Dir.exist?("statements/json")
    File.open("statements/json/#{file_name}.json", 'w') do |file|
      file.write(JSON.pretty_generate(statement_values))
    end

    return file_name
  end

  def export_csv
    #Current time formated in descending order for sorting purposes
    time = Time.new
    file_name = @account.number + '-' + time.strftime("%Y%m%d%H%M%S")

    Dir.mkdir("statements/csv") unless Dir.exist?("statements/csv")
    CSV.open("statements/csv/#{file_name}.csv", "wb") do |csv|
      csv << ['Date', 'Transaction Type', 'Amount', 'Payment Method', 'Transfer From', 'Transfer To']
      @account.deposits.each do |deposit|
        csv << [deposit.created_at, 'Deposit', deposit.amount, ' - ', ' - ', ' - ']
      end
      @account.withdrawals.each do |withdrawal|
        csv << [withdrawal.created_at, 'Withdrawal', withdrawal.amount, ' - ', ' - ', ' - ']
      end
      @account.transfers_made.each do |transfer_made|
        csv << [transfer_made.created_at, 'Transfer Made', transfer_made.amount, transfer_made.payment_method, ' Me ', transfer_made.destination_account.client.full_name]
      end
      @account.transfers_received.each do |transfer_received|
        csv << [transfer_received.created_at, 'Transfer Received', transfer_received.amount, transfer_received.payment_method, transfer_received.origin_account.client.full_name, ' Me ']
      end
    end

    return file_name
  end

  private 

  def deposits_hashes
    deposits_hashes = []
    @account.deposits.each do |deposit| 
      deposit_hash = {
        amount: deposit.amount,
        date: deposit.created_at
      }
      deposits_hashes << deposit_hash
    end
    return deposits_hashes
  end

  def withdrawals_hashes
    withdrawals_hashes = []
    @account.withdrawals.each do |withdrawal| 
      withdrawal_hash = {
        amount: withdrawal.amount,
        date: withdrawal.created_at
      }
      withdrawals_hashes << withdrawal_hash
    end
    return withdrawals_hashes
  end
  
  def transfers_made_hashes
    transfers_made_hashes = []
    @account.transfers_made.each do |transfer_made| 
      transfer_made_hash = {
        transfer_to: transfer_made.destination_account.client.full_name,
        amount: transfer_made.amount,
        payment_method: transfer_made.payment_method,
        date: transfer_made.created_at
      }
      transfers_made_hashes << transfer_made_hash
    end
    return transfers_made_hashes
  end
  
  def transfers_received_hashes
    transfers_received_hashes = []
    @account.transfers_received.each do |transfer_received| 
      transfer_received_hash = {
        transfer_from: transfer_received.origin_account.client.full_name,
        amount: transfer_received.amount,
        payment_method: transfer_received.payment_method,
        date: transfer_received.created_at
      }
      transfers_received_hashes << transfer_received_hash
    end
    return transfers_received_hashes
  end
end