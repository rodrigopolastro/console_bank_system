require 'sequel'
require 'cpf_cnpj'

Sequel.sqlite('db/bank_system.db')

require_relative 'models/client'
require_relative 'models/account'
require_relative 'models/transfer'
require_relative 'models/personal_transaction'
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
  puts '6. Edit account name'
  puts '7. Delete account'
  puts '. Generate statement'
  puts '-------------------------------'
  puts 'PERSONAL TRANSACTIONS'
  puts '9. Make deposit'
  puts '10. Withdraw money'
  puts '-------------------------------'
  puts 'TRANSFERS'
  puts '. Make Transfer'
  puts '-------------------------------'
  puts 'EXTRA: BANK ANALYSIS'
  puts '. Bank Statistics'
  puts '99. Exit'
  puts '-------------------------------'
  print 'Enter the desired option: '
  option = gets.strip.to_i

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
    answer = gets.strip

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

      client.full_name = gets.strip
      print "#{client.document_type} (only numbers): "
      client.document = gets.strip
      print 'Phone number (only numbers): '
      client.phone = gets.strip
      print 'CEP (only numbers): '
      client.zipcode = gets.strip
      print 'Federal State: '
      client.federal_state = gets.strip
      print 'City: '
      client.city = gets.strip
      print 'District: '
      client.district = gets.strip
      print 'Public Area: '
      client.public_area = gets.strip

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
      answer = gets.strip
      break if answer == '0'

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
    document = gets.strip.downcase
    if document == 'list'
      puts '-------------------------------'
      list_clients
      puts '-------------------------------'
      print "\nEnter the client CPF or CNPJ (only numbers): "
      document = gets.strip
    end

    client = Client.find(document:)

    1.times do
      break puts 'No client with given document.' if client.nil?

      puts "Accounts of '#{client.full_name}'"
      client.accounts.each do |account|
        puts " -> #{format_account_number(account.number)} - #{account.name}"
      end
      #TO-DO: Validate account unique name for current client
      #TO-DO: Validate account name -> cannot be 'Main Account'
      print "\nEnter the new account name: "
      name = gets.strip

      puts "Confirm account creation?"
      print '(Press ENTER to confirm or type 0 to cancel) -> '
      answer = gets.strip
      break if answer == '0'

      account = Account.create(name: name.strip, balance: 0)
      client.add_account(account)
      account.update(number: generate_account_number(account))

      puts "\nAccount '#{account.name}' (number: #{format_account_number(account.number)}) created sucessfully!"
    end
  when 5 #SHOW CURRENT BALANCE
    puts "ACCOUNT BALANCE (type 'list' to view registered accounts)"
    print 'Enter the account number (only numbers): '
    number = gets.strip.downcase
    if number == 'list'
      puts '-------------------------------'
      list_accounts
      puts '-------------------------------'
      print "Enter the account number (only numbers): "
      number = gets.strip
    end

    account = Account.find(number:)

    1.times do
      break puts 'No account with given number ' if account.nil?

      puts "Account #{format_account_number(account.number)} - #{account.name} of #{account.client.full_name}"
      puts "BALANCE: R$#{account.balance}"
    end
  when 6 #EDIT ACCOUNT NAME
    puts "EDITING ACCOUNT (type 'list' to view registered accounts)"
    print 'Enter the account number (only numbers): '
    number = gets.strip.downcase
    if number == 'list'
      puts '-------------------------------'
      list_accounts
      puts '-------------------------------'
      print "Enter the account number (only numbers): "
      number = gets.strip
    end

    account = Account.find(number:)
    
    1.times do
      break puts 'No account with given number. ' if account.nil?
      break puts "A client's Main Account cannot be renamed." if account.name == 'Main Account'
      
      puts "Account #{format_account_number(number)} - #{account.name} of #{account.client.full_name}"
      puts "BALANCE: R$#{account.balance}"
      print "\nNew account name: "
      account.name = gets.strip

      puts "\nConfirm account edition? (Press ENTER to confirm or type 0 to cancel)"
      print " -> "
      answer = gets.strip
      break puts 'Edition canceled' if answer == '0'

      #TO-DO: Validate if's a number
      #TO-DO: Validate account unique name for current client
      account.save
      puts "Account updated successfully!"
    end
  when 7 #DELETE ACCOUNT
    puts "DELETING ACCOUNT (type 'list' to view registered accounts)"
    print 'Enter the account number (only numbers): '
    number = gets.strip.downcase
    if number == 'list'
      puts '-------------------------------'
      list_accounts
      puts '-------------------------------'
      print "Enter the account number (only numbers): "
      number = gets.strip
    end

    account = Account.find(number:)
    
    1.times do
      break puts 'No account with given number ' if account.nil?
      break puts "A client's Main Account cannot be deleted" if account.name == 'Main Account'
      
      puts "Account #{format_account_number(number)} - #{account.name} of #{account.client.full_name}"
      puts "BALANCE: R$#{account.balance}"

      puts "\nDeleting this account will transfer all of its balance to #{account.client.full_name}'s Main Account."
      puts "Confirm account edition? (Press ENTER to confirm or type 0 to cancel)"
      print ' -> '
      answer = gets.strip
      break puts 'Deletion canceled' if answer == '0'

      #Select Main Account of the client that owns the account being deleted
      main_account = account.client.accounts.find{|account| account.name == 'Main Account'}

      if account.balance > 0
        Transfer.create(
          origin_account_id: main_account.id,
          destination_account_id: account.id,
          amount: account.balance
        )
      end
      account.delete
      puts "Account deleted successfully!"
    end
  when 9 #MAKE DEPOSIT
    personal_transaction = PersonalTransaction.new
    personal_transaction.transaction_type = 'deposit'

    puts "MAKING DEPOSIT (type 'list' to view registered accounts)"
    print 'Enter the account number (only numbers): '
    number = gets.strip.downcase
    if number == 'list'
      puts '-------------------------------'
      list_accounts
      puts '-------------------------------'
      print "Enter the account number (only numbers): "
      number = gets.strip
    end

    account = Account.find(number:)
    
    1.times do
      break puts 'No account with given number. ' if account.nil?
      
      personal_transaction.account_id = account.id
      puts "Account #{format_account_number(number)} - #{account.name} of #{account.client.full_name}"
      puts "BALANCE: R$#{account.balance}"
      print "\nDeposit value: "
      amount = gets.strip.to_f

      break puts "The deposit value must be greater than 0." if amount <= 0

      puts "\nConfirm deposit? (Press ENTER to confirm or type 0 to cancel)"
      print " -> "
      answer = gets.strip
      break puts 'Deposit canceled' if answer == '0'

      new_balance = account.balance + amount
      account.update(balance: new_balance)

      personal_transaction.amount = amount
      personal_transaction.save
      puts "Deposit of R$#{amount} made successfully!"
      puts "NEW BALANCE: R$#{new_balance}"
    end
  when 10 #MAKE WITHDRAWAL
    personal_transaction = PersonalTransaction.new
    personal_transaction.transaction_type = 'withdrawal'

    puts "MAKING WITHDRAWAL (type 'list' to view registered accounts)"
    print 'Enter the account number (only numbers): '
    number = gets.strip.downcase
    if number == 'list'
      puts '-------------------------------'
      list_accounts
      puts '-------------------------------'
      print "Enter the account number (only numbers): "
      number = gets.strip
    end

    account = Account.find(number:)
    
    1.times do
      break puts 'No account with given number. ' if account.nil?
      
      personal_transaction.account_id = account.id
      puts "Account #{format_account_number(number)} - #{account.name} of #{account.client.full_name}"
      puts "BALANCE: R$#{account.balance}"
      print "\nWithdrawal value: "
      amount = gets.strip.to_f

      break puts "The withdrawal value must be a number greater than 0." if amount <= 0
      
      if amount > account.balance
        puts 'The account balance is too low for the withdrawal.'
        break puts 'Withdrawal cancelled: Your overdraft limit is R$100.00' if account.balance - amount < -100
        
        print 'Would you link to go into overdraft? [y/n]'
        answer = gets.strip

        break puts 'Deposit canceled.' unless affirmative?(answer)
      end
      
      new_balance = account.balance - amount
      account.update(balance: new_balance)

      personal_transaction.amount = amount
      personal_transaction.save
      puts "Withdrawal of R$#{amount} made successfully!"
      puts "NEW BALANCE: R$#{new_balance}"
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

