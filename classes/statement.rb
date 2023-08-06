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

    total_income  = deposits_sum + transfers_received_sum
    total_outcome = withdrawals_sum + transfers_made_sum
  
    statement_values = {
      account_number:,
      account_name:,
      owner_document_type:,
      owner_document:,
      owner_name:,
      total_income:,
      total_outcome:,
      deposits: deposits_hash_list,
      withdrawals: withdrawals_hash_list,
      transfers_made: transfers_made_hash_list,
      transfers_received: transfers_received_hash_list
    }
  
    Dir.mkdir("statements/json") unless Dir.exist?("statements/json")
    File.open("statements/json/#{file_name}.json", 'w') do |file|
      file.write(JSON.pretty_generate(statement_values))
    end

    return file_name
  end

  private 

  def deposits_objects
    @account.personal_transactions.select{|t| t.transaction_type == 'deposit'}
  end

  def withdrawals_objects
    @account.personal_transactions.select{|t| t.transaction_type == 'deposit'}
  end

  def transfers_made_objects
    @account.transfers_made
  end

  def transfers_received_objects
    @account.transfers_received
  end

  def deposits_sum
    deposits_objects.sum{|d| d.amount}
  end

  def withdrawals_sum
    withdrawals_objects.sum{|w| w.amount}
  end

  def transfers_made_sum
    transfers_made_objects.sum{|tm| tm.amount}
  end

  def transfers_received_sum
    transfers_received_objects.sum{|tr| tr.amount}
  end

  def deposits_hash_list
    deposits = []
    deposits_objects.each do |deposit_object| 
      deposit_hash = {
        amount: deposit_object.amount,
        date: deposit_object.created_at
      }
      deposits << deposit_hash
    end
  end

  def withdrawals_hash_list
    withdrawals = []
    withdrawals_objects.each do |withdrawal_object| 
      withdrawal_hash = {
        amount: withdrawal_object.amount,
        date: withdrawal_object.created_at
      }
      withdrawals << withdrawal_hash
    end
  end
  
  def transfers_made_hash_list
    transfers_made = []
    transfers_made_objects.each do |transfer_made| 
      transfer_made_hash = {
        transfer_to: transfer_made.destination_account.client.full_name,
        amount: transfer_made.amount,
        date: transfer_made.created_at
      }
      transfers_made << transfer_made_hash
    end
  end
  
  def transfers_received_hash_list
    transfers_received = []
    transfers_received_objects.each do |transfer_received| 
      transfer_received_hash = {
        transfer_from: transfer_received.origin_account.client.full_name,
        amount: transfer_received.amount,
        date: transfer_received.created_at
      }
      transfers_received << transfer_received_hash
    end
  end
end