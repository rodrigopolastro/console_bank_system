require 'sequel'
require 'cpf_cnpj'
require 'faker'
Faker::Config.locale = 'pt-BR'

Sequel.sqlite('db/bank_system.db')

require_relative 'models/client'
require_relative 'models/account'
require_relative 'models/personal_transaction'
require_relative 'models/transfer'
require_relative 'helpers/generate_account_number'
require_relative 'helpers/generate_phone_number'

# Natural Persons
document_type = 'CPF'
Client.multi_insert([
  {
    full_name: 'Rodrigo Polastro da Silva',
    document_type:,
    document: CPF.generate,
    phone: generate_phone_number,
    #Adress-related fields
    federal_state: Faker::Adress.state,
    city:          Faker::Adress.city,
    district:      'Central District'
    public_area:   Faker::Adress.street
    postcode:      Faker::Adress.postcode
  }, 
  {
    full_name: 'Renato Mantovani',
    document_type:,
    document: CPF.generate,
    phone: generate_phone_number,
    #Adress-related fields
    federal_state: Faker::Adress.state,
    city:          Faker::Adress.city,
    district:      'Central District'
    public_area:   Faker::Adress.street
    postcode:      Faker::Adress.postcode
  },
  {
    full_name: 'Jonas Montedioca',
    document_type:,
    document: CPF.generate,
    phone: generate_phone_number,
    #Adress-related fields
    federal_state: Faker::Adress.state,
    city:          Faker::Adress.city,
    district:      'Central District'
    public_area:   Faker::Adress.street
    postcode:      Faker::Adress.postcode
  }
])

# Legal Persons
document_type = 'CNPJ'
Client.multi_insert([
  {
    full_name: 'Spinelli Racing',
    document_type:,
    document: CNPJ.generate,
    phone: generate_phone_number,
    #Adress-related fields
    federal_state: Faker::Adress.state,
    city:          Faker::Adress.city,
    district:      'Central District'
    public_area:   Faker::Adress.street
    postcode:      Faker::Adress.postcode
  }, 
  {
    full_name: 'Kazap Tecnologia',
    document_type:,
    document: CNPJ.generate,
    phone: generate_phone_number,
    #Adress-related fields
    federal_state: Faker::Adress.state,
    city:          Faker::Adress.city,
    district:      'Central District'
    public_area:   Faker::Adress.street
    postcode:      Faker::Adress.postcode
  }, 
])

# All clients have a 'Main Account' by default
clients = Client.all
clients.each do |client|
  account = Account.create(name: 'Main Account', balance: 0)
  client.add_account(account)
  account.update(number: generate_account_number(account))
end
