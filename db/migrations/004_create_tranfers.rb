require 'sequel'

Sequel.migration do 
  change do 
    create_table :transfers do
      primary_key :id
      foreign_key :origin_account_id, :accounts
      foreign_key :destination_account_id, :accounts

      String :transfer_type, size: 3
      Float :amount
    end
  end
end