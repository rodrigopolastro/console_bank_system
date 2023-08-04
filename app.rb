require 'sequel'
require 'cpf_cnpj'

Sequel.sqlite('db/bank_system.db')

require_relative 'models/client'
require_relative 'models/account'
require_relative 'config/test_mode.rb'
loop do
  system("clear")

  #IDEA -> General and Specific options:
  #     -> General options = bank related
  #     -> Specific options = user related (one client at a time)
  puts '>>>>> CONSOLE BANK SYSTEM <<<<<'
  puts '-------------------------------'
  puts 'CLIENTS'
  puts '1. List clients'
  puts '2. Register natural person'
  puts '3. Register legal person'
  puts '-------------------------------'
  puts 'ACCOUNTS'
  puts '4. List all accounts'
  puts '. List accounts of one client'
  puts '. Show account balance'
  puts '. Generate statement'
  puts '. Create account'
  puts '. Edit account'
  puts '. Delete account'
  puts '-------------------------------'
  puts 'PERSONAL TRANSACTIONS'
  puts '. Make deposit'
  puts '. Withdraw money'
  puts '-------------------------------'
  puts 'TRANSFERS'
  puts '. Make Transfer'
  puts '-------------------------------'
  puts '0. Exit'
  puts '-------------------------------'
  print 'Enter the desired option: '
  option = gets.chomp.to_i
  puts ""

  case option
  when 1 #LIST CLIENTS
    puts 'NATURAL PERSONS'
    natural_persons = Client.where(document_type: 'CPF').all

    natural_persons.each do |natural_person|
      cpf = CPF.new(natural_person.document)
      puts "#{natural_person.full_name} - CPF: #{cpf.formatted}"
    end
    puts '-------------------------------'
    puts 'LEGAL PERSONS'
    legal_persons   = Client.where(document_type: 'CNPJ').all

    legal_persons.each do |legal_person|
      cnpj = CNPJ.new(legal_person.document)
      puts "#{legal_person.full_name} - CNPJ: #{cnpj.formatted}"
    end
  when 2 #REGISTER NATURAL PERSON
    client = Client.new
    client.document_type = 'CPF'

    puts 'REGISTERING NATURAL PERSON'
    print 'Client full name: '
    client.full_name = gets.chomp
    print 'CPF (only numbers): '
    client.document = gets.chomp
    print 'Phone number (only numbers): '
    client.phone = gets.chomp
    print 'Zipcode or CEP (only numbers): '
    client.zipcode = gets.chomp
    print 'Federal State: '
    client.federal_state = gets.chomp
    print 'City: '
    client.city = gets.chomp
    print 'District: '
    client.district = gets.chomp
    print 'Public Area: '
    client.public_area = gets.chomp

    if(GENERATE_SAMPLE_CPF)
      client.document = SAMPLE_CPF
    end

    if(GENERATE_SAMPLE_PHONE)
      client.phone = SAMPLE_PHONE
    end

    if(GENERATE_SAMPLE_ADRESS)
      client.zipcode       = SAMPLE_ADRESS[:zipcode]
      client.federal_state = SAMPLE_ADRESS[:federal_state]
      client.city          = SAMPLE_ADRESS[:city]
      client.district      = SAMPLE_ADRESS[:district]
      client.public_area   = SAMPLE_ADRESS[:public_area]
    end
    client.save

    cpf = CPF.new(client.document)
    puts "\nNatural person '#{client.full_name}' (CPF: #{cpf.formatted}) created successfully!"
  when 3 #REGISTER LEGAL PERSON
    client = Client.new
    client.document_type = 'CNPJ'

    puts 'REGISTERING LEGAL PERSON'
    print 'Company full name: '
    client.full_name = gets.chomp
    print 'CNPJ (only numbers): '
    client.document = gets.chomp
    print 'Phone number (only numbers): '
    client.phone = gets.chomp
    print 'Zipcode or CEP(only numbers): '
    client.zipcode = gets.chomp
    print 'Federal State: '
    client.federal_state = gets.chomp
    print 'City: '
    client.city = gets.chomp
    print 'District: '
    client.district = gets.chomp
    print 'Public Area: '
    client.public_area = gets.chomp

    if(GENERATE_SAMPLE_CNPJ)
      client.document = SAMPLE_CNPJ
    end

    if(GENERATE_SAMPLE_PHONE)
      client.phone = SAMPLE_PHONE
    end

    if(GENERATE_SAMPLE_ADRESS)
      client.zipcode       = SAMPLE_ADRESS[:zipcode]
      client.federal_state = SAMPLE_ADRESS[:federal_state]
      client.city          = SAMPLE_ADRESS[:city]
      client.district      = SAMPLE_ADRESS[:district]
      client.public_area   = SAMPLE_ADRESS[:public_area]
    end
    client.save
    
    cnpj = CNPJ.new(client.document)
    puts "\nLegal person '#{client.full_name}' (CNPJ: #{cnpj.formatted}) created successfully!"
  when 4 #LIST ALL ACCOUNTS    
    puts 'NATURAL PERSONS ACCOUNTS'
    natural_persons = Client.where(document_type: 'CPF').all

    natural_persons.each do |natural_person|
      cpf = CPF.new(natural_person.document)
      puts "\n#{natural_person.full_name} - CPF: #{cpf.formatted}"
      
      natural_person.accounts.each do |account|
        puts " -> Account Number: #{account.id} - #{account.name}"
      end
    end
    puts '-------------------------------'
    puts 'LEGAL PERSONS'
    legal_persons   = Client.where(document_type: 'CNPJ').all

    legal_persons.each do |legal_person|
      cnpj = CNPJ.new(legal_person.document)
      puts "\n#{legal_person.full_name} - CNPJ: #{cnpj.formatted}"
      
      legal_person.accounts.each do |account|
        puts " -> Account Number: #{account.id} - #{account.name}"
      end
    end
  when 0
    puts 'Encerrando sistema...'
    break
  else
    puts 'Opção Inválida.'
  end
  print "\nAperte ENTER para voltar..."
  waiting_variable = gets
end

