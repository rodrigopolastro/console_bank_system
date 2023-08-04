require 'sequel'

Sequel.migration do 
  change do
    alter_table :personal_transactions do
      set_column_type :transaction_type, String, size: 10
    end
  end
end