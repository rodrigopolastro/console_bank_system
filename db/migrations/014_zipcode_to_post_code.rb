require 'sequel'

Sequel.migration do 
  change do
    alter_table :clients do
      rename_column :zipcode, :postcode
    end
  end
end