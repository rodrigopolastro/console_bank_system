require 'sequel'

Sequel.migration do 
  change do
    alter_table :clients do
      add_column :created_at, DateTime, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end