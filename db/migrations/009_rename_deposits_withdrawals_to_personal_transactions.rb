require 'sequel'

Sequel.migration do
  change do
    rename_table :deposits_withdrawals, :personal_transactions
  end 
end