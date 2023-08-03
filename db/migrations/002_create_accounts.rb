require 'sequel'

Sequel.migration do
  change do 
    create_table :accounts do
      primary_key :id
      foreign_key :client_id, :clients
      
      String :name, size: 50, null: false
      Float :balance, null: false
    end   
  end
end