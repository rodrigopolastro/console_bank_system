require 'sequel'
require 'cpf_cnpj'

Sequel.sqlite('db/bank_system.db')

require_relative 'models/client'
require_relative 'models/account'
require_relative 'helpers/validate_answer'
require_relative 'helpers/generate_account_number'

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
  puts '2. Register client'
  puts '-------------------------------'
  puts 'ACCOUNTS'
  puts '3. List all accounts'
  puts '4. Create new account'
  puts '5. Show account balance'
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
  puts '99. Exit'
  puts '-------------------------------'
  print 'Enter the desired option: '
  option = gets.chomp.to_i

  system("clear")

  def list_clients
    puts 'NATURAL PERSONS'
    natural_persons = Client.where(document_type: 'CPF').all

    natural_persons.each do |natural_person|
      cpf = CPF.new(natural_person.document)
      #TO-DO: set a 50 length space (max size name) here to display cpfs aligned
      puts "#{natural_person.full_name} - CPF: #{cpf.formatted}"
    end
    puts '-------------------------------'
    puts 'LEGAL PERSONS'
    legal_persons   = Client.where(document_type: 'CNPJ').all

    legal_persons.each do |legal_person|
      cnpj = CNPJ.new(legal_person.document)
      puts "#{legal_person.full_name} - CNPJ: #{cnpj.formatted}"
    end
  end

  def list_accounts
    puts 'NATURAL PERSONS ACCOUNTS'
    natural_persons = Client.where(document_type: 'CPF').all

    natural_persons.each do |natural_person|
      cpf = CPF.new(natural_person.document)
      puts "\n#{natural_person.full_name} - CPF: #{cpf.formatted}"

      natural_person.accounts.each do |account|
        puts " -> #{format_account_number(account.number)} - #{account.name}"
      end
    end
    puts '-------------------------------'
    puts 'LEGAL PERSONS ACCOUNTS'
    legal_persons   = Client.where(document_type: 'CNPJ').all

    legal_persons.each do |legal_person|
      cnpj = CNPJ.new(legal_person.document)
      puts "\n#{legal_person.full_name} - CNPJ: #{cnpj.formatted}"

      legal_person.accounts.each do |account|
        puts " -> #{format_account_number(account.number)} - #{account.name}"
      end
    end
  end

  case option
  when 1 #LIST CLIENTS
    list_clients
  when 2 #REGISTER CLIENT
    client = Client.new

    print 'Is this client a natural person? [y/n] '
    answer = gets.chomp

    #Loop to exit form for invalid input
    1.times do
      if affirmative?(answer)
        client.document_type = 'CPF'
        puts "\nREGISTERING NATURAL PERSON"
        print 'Client full name: '
      elsif negative?(answer)
        client.document_type = 'CNPJ'
        puts "\nREGISTERING LEGAL PERSON"
        print 'Company full name: '
      else
        puts 'Resposta inválida.'
        break #Break internal loop, not the application's loop
      end

      client.full_name = gets.chomp
      print "#{client.document_type} (only numbers): "
      client.document = gets.chomp
      print 'Phone number (only numbers): '
      client.phone = gets.chomp
      print 'CEP (only numbers): '
      client.zipcode = gets.chomp
      print 'Federal State: '
      client.federal_state = gets.chomp
      print 'City: '
      client.city = gets.chomp
      print 'District: '
      client.district = gets.chomp
      print 'Public Area: '
      client.public_area = gets.chomp

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

      puts "\nConfirm client creation?"
      print '(Press ENTER to confirm or type 0 to cancel) -> '
      answer = gets.chomp
      break if answer == 0

      if client.document_type == 'CPF'
        if GENERATE_SAMPLE_DOCUMENT
          client.document = SAMPLE_CPF
        end
        cpf = CPF.new(client.document)
        puts "\nNatural person '#{client.full_name}' (CPF: #{cpf.formatted}) created successfully!"
      else
        if GENERATE_SAMPLE_DOCUMENT
          client.document = SAMPLE_CNPJ
        end
        cnpj = CNPJ.new(client.document)
        puts "\nLegal person '#{client.full_name}' (CNPJ: #{cnpj.formatted}) created successfully!"
      end

      client.save

      account = Account.create(name: 'Main Account', balance: 0)
      client.add_account(account)
    end
  when 3 #LIST ALL ACCOUNTS
    list_accounts
  when 4 #CREATE NEW ACCOUNT
    client = Client.new

    puts "CREATING ACCOUNT (type 'list' to view registered clients)"
    print 'Enter the client CPF or CNPJ (only numbers): '
    document = gets.chomp.downcase
    if document == 'list'
      puts '-------------------------------'
      list_clients
      puts '-------------------------------'
      print "\nEnter the client CPF or CNPJ (only numbers): "
      document = gets.chomp
    end

    client = Client.find(document:)

    1.times do
      break puts 'No client with given document.' if client.nil?

      puts "Accounts of '#{client.full_name}'"
      client.accounts.each do |account|
        puts " -> #{format_account_number(account.number)} - #{account.name}"
      end
      #TO-DO: Validate account unique name for current client
      print "\nEnter the new account name: "
      name = gets.chomp

      puts "Confirm account creation?"
      print '(Press ENTER to confirm or type 0 to cancel) -> '
      answer = gets.chomp
      break if answer == '0'

      account = Account.create(name:, balance: 0)
      client.add_account(account)

      puts "\nAccount '#{account.name}' (number: #{format_account_number(account.number)}) created sucessfully!"
    end
  when 5 #SHOW CURRENT BALANCE
    puts "ACCOUNT BALANCE (type 'list' to view registered accounts)"
    print 'Enter the account number (only numbers): '
    number = gets.chomp.downcase
    if number == 'list'
      puts '-------------------------------'
      list_accounts
      puts '-------------------------------'
      print "Enter the account number (only numbers): "
      number = gets.chomp
    end

    account = Account.find(number:)

    1.times do
      break puts 'No account with given number ' if account.nil?

      puts "#{format_account_number(account.number)} - #{account.name} of #{account.client.full_name}"
      puts "BALANCE: R$#{account.balance}"
    end
  when 99
    puts 'System shutting down...'
    break
  else
    puts 'Invalid option.'
  end
  print "\nPress ENTER to return..."
  waiting_variable = gets
end

