require 'sequel'

Sequel.migration do 
  change do
    alter_table :personal_transactions do
      rename_column :is_deposit?, :transaction_type
    end
  end
end