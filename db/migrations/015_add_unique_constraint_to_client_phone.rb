require 'sequel'

Sequel.migration do 
  change do
    alter_table :clients do
      add_unique_constraint :phone
    end
  end
end