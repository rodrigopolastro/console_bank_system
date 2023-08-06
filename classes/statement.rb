require 'json'

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
      deposits:,
      withdrawals:,
      transfers_made:,
      transfers_received:
    }
  
    Dir.mkdir("statements/json") unless Dir.exist?("statements/json")
    File.open("statements/json/#{file_name}.json", 'w') do |file|
      file.write(JSON.pretty_generate(statement_values))
    end

    return file_name
  end

  private 

  def deposits
    deposits = []
    @account.deposits.each do |deposit| 
      deposit_hash = {
        amount: deposit.amount,
        date: deposit.created_at
      }
      deposits << deposit_hash
    end
    return deposits
  end

  def withdrawals
    withdrawals = []
    @account.withdrawals.each do |withdrawal| 
      withdrawal_hash = {
        amount: withdrawal.amount,
        date: withdrawal.created_at
      }
      withdrawals << withdrawal_hash
    end
    return withdrawals
  end
  
  def transfers_made
    transfers_made = []
    @account.transfers_made.each do |transfer_made| 
      transfer_made_hash = {
        transfer_to: transfer_made.destination_account.client.full_name,
        amount: transfer_made.amount,
        date: transfer_made.created_at
      }
      transfers_made << transfer_made_hash
    end
    return transfers_made
  end
  
  def transfers_received
    transfers_received = []
    @account.transfers_received.each do |transfer_received| 
      transfer_received_hash = {
        transfer_from: transfer_received.origin_account.client.full_name,
        amount: transfer_received.amount,
        date: transfer_received.created_at
      }
      transfers_received << transfer_received_hash
    end
    return transfers_received
  end
end