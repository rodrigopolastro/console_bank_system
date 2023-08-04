class Account < Sequel::Model
  many_to_one :client

  one_to_many :personal_transactions

  one_to_many :transfers_made,     class: :Transfer, key: :origin_account_id
  one_to_many :transfers_received, class: :Transfer, key: :destination_account_id
end