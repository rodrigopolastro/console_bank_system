require 'sequel'

Sequel.migration do 
  change do 
    create_table :deposits_withdrawals do
      primary_key :id
      foreign_key :account_id, :accounts

      Boolean :is_deposit?
      Float :amount
    end
    
  end
end