class Account < Sequel::Model
  many_to_one :client

  one_to_many :personal_transactions

  one_to_many :transfers_made,     class: :Transfer, key: :origin_account_id
  one_to_many :transfers_received, class: :Transfer, key: :destination_account_id

  def deposits
    personal_transactions.select{|t| t.transaction_type == 'deposit'}
  end

  def withdrawals
    personal_transactions.select{|t| t.transaction_type == 'deposit'}
  end

  def deposits_sum
    deposits.sum{|d| d.amount}
  end

  def withdrawals_sum
    withdrawals.sum{|w| w.amount}
  end

  def transfers_made_sum
    transfers_made.sum{|tm| tm.amount}
  end

  def transfers_received_sum
    transfers_received.sum{|tr| tr.amount}
  end
end