require 'sequel'

Sequel.migration do 
  change do
    alter_table :accounts do
      add_column :days_in_overdraft, Integer, default: 0
    end
  end
end