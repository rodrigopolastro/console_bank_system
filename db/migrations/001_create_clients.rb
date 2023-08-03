require 'sequel'

Sequel.migration do
  change do
    create_table :clients do
      primary_key :id
      
      # Both for person and company
      String :full_name    , size: 50, null: false    
      
      # 'CPF' or 'CNPJ'
      String :document_type, size: 4,  null: false 
      
      # Only numbers
      String :document     , size: 14, null: false, unique: true
      String :phone        , size: 11, null: false

      # Adress-related fields
      String :federal_state, size: 2,  null: false
      String :city         , size: 50, null: false
      String :district     , size: 50, null: false
      String :public_area  , size: 50, null: false
      String :zipcode      , size: 8,  null: false
    end
  end
end