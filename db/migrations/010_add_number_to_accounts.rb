require 'sequel'

Sequel.migration do 
  change do
    alter_table :accounts do
      add_column :number, String, size: 9
    end
  end
end