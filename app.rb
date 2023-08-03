require 'sequel'
require 'cpf_cnpj'

Sequel.sqlite('db/bank_system.db')

require_relative 'models/client'
require_relative 'config/test_mode.rb'
loop do
  system("clear")

  puts '>>>>> CONSOLE BANK SYSTEM <<<<<'
  puts '-------------------------------'
  puts 'CLIENTS'
  puts '1. List clients'
  puts '2. Register natural person'
  puts '3. Register legal person'
  puts '-------------------------------'
  puts 'ACCOUNTS'
  puts '4. List accounts'
  puts '5. Show account balance'
  puts '6. Generate statement'
  puts '7. Create account'
  puts '8. Edit account'
  puts '9. Delete account'
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
  when 1 
    natural_persons = Client.where(document_type: 'CPF').all
    legal_persons   = Client.where(document_type: 'CNPJ').all

    puts 'NATURAL PERSONS'
    natural_persons.each do |natural_person|
      cpf = CPF.new(natural_person.document)
      puts "#{natural_person.full_name} - CPF: #{cpf.formatted}"
    end
    puts '-------------------------------'
    puts 'LEGAL PERSONS'
    legal_persons.each do |legal_person|
      cnpj = CNPJ.new(legal_person.document)
      puts "#{legal_person.full_name} - CNPJ: #{cnpj.formatted}"
    end
  when 2
    client = Client.new
    client.document_type = 'CPF'

    puts 'REGISTERING NATURAL PERSON'
    print 'Client full name: '
    client.full_name = gets.chomp
    print 'CPF (only numbers): '
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

    puts "\nNatural person '#{client.full_name}' created successfully!"
  when 3
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

    puts "\nLegal person '#{client.full_name}' created successfully!"
  when 0
    puts 'Encerrando sistema...'
    break
  else
    puts 'Opção Inválida.'
  end
  print "\nAperte ENTER para voltar..."
  waiting_variable = gets
end

