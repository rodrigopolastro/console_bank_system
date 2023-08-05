require 'sequel'

Sequel.migration do 
  change do
    alter_table :transfers do
      rename_column :transfer_type, :payment_method
    end
  end
end