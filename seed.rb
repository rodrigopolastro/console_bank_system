require 'sequel'
require 'cpf_cnpj'

Sequel.sqlite('db/bank_system.db')

require_relative 'models/client'
require_relative 'models/account'
require_relative 'models/personal_transaction'
require_relative 'models/transfer'
require_relative 'helpers/generate-account_number'
sample_adress = {
  federal_state: 'SP',
  city: 'Mogi Guaçu',
  district: 'Ipê 8',
  public_area: 'Rua dos Pinheiros',
  zipcode: '12345678'
}

# Natural Persons
document_type = 'CPF'
Client.multi_insert([
  {
    full_name: 'Rodrigo Polastro da Silva',
    document_type:,
    document: CPF.generate,
    phone: 19912345678,
    #Adress-related fields
    federal_state: sample_adress[:federal_state],
    city:          sample_adress[:city],
    district:      sample_adress[:district],
    public_area:   sample_adress[:public_area],
    zipcode:       sample_adress[:zipcode],
  }, 
  {
    full_name: 'Renato Mantovani',
    document_type:,
    document: CPF.generate,
    phone: 19911112222,
    #Adress-related fields
    federal_state: sample_adress[:federal_state],
    city:          sample_adress[:city],
    district:      sample_adress[:district],
    public_area:   sample_adress[:public_area],
    zipcode:       sample_adress[:zipcode],
  },
  {
    full_name: 'Jonas Montedioca',
    document_type:,
    document: CPF.generate,
    phone: 19977778888,
    #Adress-related fields
    federal_state: sample_adress[:federal_state],
    city:          sample_adress[:city],
    district:      sample_adress[:district],
    public_area:   sample_adress[:public_area],
    zipcode:       sample_adress[:zipcode],
  }
])

# Legal Persons
document_type = 'CNPJ'
Client.multi_insert([
  {
    full_name: 'Spinelli Racing',
    document_type:,
    document: CNPJ.generate,
    phone: 1944445555,
    #Adress-related fields
    federal_state: sample_adress[:federal_state],
    city:          sample_adress[:city],
    district:      sample_adress[:district],
    public_area:   sample_adress[:public_area],
    zipcode:       sample_adress[:zipcode],
  }, 
  {
    full_name: 'Kazap Tecnologia',
    document_type:,
    document: CNPJ.generate,
    phone: 1938415622,
    #Adress-related fields
    federal_state: sample_adress[:federal_state],
    city:          sample_adress[:city],
    district:      sample_adress[:district],
    public_area:   sample_adress[:public_area],
    zipcode:       sample_adress[:zipcode],
  }, 
])

# All clients have a 'Main Account' by default
clients = Client.all
clients.each do |client|
  account = Account.create(name: 'Main Account', balance: 0)
  client.add_account(account)
  account.update(number: generate_account_number(account))
end
