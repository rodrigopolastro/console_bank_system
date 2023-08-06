require 'sequel'
require 'cpf_cnpj'

Sequel.sqlite('db/bank_system.db')

require_relative 'models/client'
require_relative 'models/account'
require_relative 'models/transfer'
require_relative 'models/personal_transaction'
require_relative 'classes/statement.rb'
require_relative 'helpers/validate_answer'
require_relative 'helpers/generate_account_number'

require_relative 'config/test_mode.rb'
loop do
  system("clear")
  puts '-----------------------------------'
  puts '| >>>>> CONSOLE BANK SYSTEM <<<<< |'
  puts '|---------------------------------|'
  puts '| CLIENTS                         |'
  puts '| 1. List clients                 |'
  puts '| 2. Register client              |'
  puts '|---------------------------------|'
  puts '| ACCOUNTS                        |'
  puts '| 3. List all accounts            |'
  puts '| 4. Create new account           |'
  puts '| 5. Show account balance         |'
  puts '| 6. Edit account name            |'
  puts '| 7. Delete account               |'
  puts '| 8. Generate statement           |'
  puts '|---------------------------------|'
  puts '| PERSONAL TRANSACTIONS           |'
  puts '| 9. Make deposit                 |'
  puts '| 10. Withdraw money              |'
  puts '|---------------------------------|'
  puts '| TRANSFERS                       |'
  puts '| 11. Make Transfer               |'
  puts '|---------------------------------|'
  puts '| EXTRA: BANK ANALYSIS            |'
  puts '| . Bank Statistics               |'
  puts '|---------------------------------|'
  puts '| 99. Exit                        |'
  puts '-----------------------------------'
  print 'Enter the desired option number: '
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
      account.update(number: generate_account_number(account))
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
          payment_method: 'PIX',
          amount: account.balance
        )
      end
      account.delete
      puts "Account deleted successfully!"
    end
  when 8 #GENERATE STATEMENT
    puts "GENERATING STATEMENT (type 'list' to view registered accounts)"
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
      system("clear")
      owner = account.client
      if owner.document_type == 'CPF'
        document = CPF.new(owner.document)
      else 
        document = CNPJ.new(owner.document)
      end
      personal_transactions = account.personal_transactions
      personal_transactions.sort_by{|transaction| transaction.created_at }.reverse!.take(10)

      transfers = account.transfers_made + account.transfers_received
      transfers.sort_by{|transfer| transfer.created_at}.reverse!.take(10)
      puts '-------------------------------'
      puts 'BANK OFICIAL STATEMENT'
      puts '-------------------------------'
      puts "Account Name: #{account.name} - Number: #{format_account_number(account.number)}"
      puts "Owner: #{owner.full_name} - #{owner.document_type}: #{document.formatted}"
      puts "Creation date: #{account.created_at}"
      puts '-------------------------------'
      puts "DEPOSITS AND WITHDRAWALS (last 10)"
      personal_transactions.each do |transaction|
        puts "\n -> #{transaction.transaction_type.capitalize} - #{transaction.created_at}"
        if transaction.transaction_type == 'deposit'
          puts "    Amount: +R$#{transaction.amount}"
        else
          puts "    Amount: -R$#{transaction.amount}"
        end
      end
      puts '-------------------------------'
      puts "TRANSFERS (last 10)"
      transfers.each do |transfer|
        if account.transfers_made.include?(transfer)
          puts "\n -> Transfer Made to #{transfer.destination_account.client.full_name} - #{transfer.created_at}"
          puts "    Amount: -R$#{transfer.amount}"
        else
          puts "\n -> Transfer Received from #{transfer.destination_account.client.full_name} - #{transfer.created_at}"
          puts "    Amount: +R$#{transfer.amount}"
        end
      end
      all_transactions = personal_transactions + transfers
      deposits    = personal_transactions.select{|t| t.transaction_type == 'deposit'}
      withdrawals = personal_transactions.select{|t| t.transaction_type == 'withdrawal'}

      deposits_amount    = deposits.sum{|d| d.amount}
      withdrawals_amount = withdrawals.sum{|w| w.amount}
      transfers_made_amount     = account.transfers_made.sum{|tm| tm.amount}
      transfers_received_amount = account.transfers_received.sum{|tr| tr.amount}

      income = deposits_amount + transfers_received_amount
      outcome = withdrawals_amount + transfers_made_amount

      oldest_transaction = all_transactions.sort_by{|t| t.created_at }.first
      puts '-------------------------------'
      puts "PERIOD SHOWED: All transactions since #{oldest_transaction.created_at})"
      puts "\nPeriod Income:  +R$#{income}"
      puts "Period Outcome: -R$#{outcome}"
      former_balance = account.balance - income + outcome
      puts "Former Balance:  R$#{former_balance}"
      puts "Current Balance: R$#{account.balance}"
      signal = account.balance - former_balance >= 0 ? '+' : ''
      puts "Period Result:   R$#{signal}#{account.balance - former_balance}"
      puts '-------------------------------'
      puts 'To view all the transactions you need to export the statement.'
      print 'Would you like to export the statement? [y/n] '
      answer = gets.strip 

      if affirmative?(answer)
        puts 'Choose the desired export format'
        puts '1. JSON'
        puts '2. CSV'
        print '-> '
        export_format = gets.strip.to_i

        case export_format
        when 1 
          statement = Statement.new(account)
          file_name = statement.export_json
          puts "JSON statement exported sucessfully!"
          puts "Look up the statements/json folder for the file: #{file_name}.json"
        when 2
          # statement = Statement.new(account)
          # file_name = statement.export_csv
          # puts "CSV statement exported sucessfully!"
          # puts "Look up the statements/csv folder for the file: #{file_name}.csv"
        else
          puts 'Invalid export format.'
        end
      end
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
      system("clear")
      
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
      personal_transaction = PersonalTransaction.new
      personal_transaction.transaction_type = 'withdrawal'
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
  when 11 #MAKE TRANSFER
    puts "MAKING TRANSFER (type 'list' to view registered accounts)"
    print 'Enter the origin account number (only numbers): '
    origin_number = gets.strip.downcase
    if origin_number == 'list'
      puts '-------------------------------'
      list_accounts
      puts '-------------------------------'
      print "Enter the origin account number (only numbers): "
      origin_number = gets.strip
    end

    origin_account = Account.find(number: origin_number)
    
    1.times do
      break puts 'No account with given number.' if origin_account.nil?
      break puts 'The informed account does not have funds.' if origin_account.balance <= 0
      transfer = Transfer.new
      transfer.origin_account_id = origin_account.id
      
      system("clear")
      puts '-------------------------------'
      puts 'ORIGIN ACCOUNT'
      puts "Account #{format_account_number(origin_number)} - #{origin_account.name} of #{origin_account.client.full_name}"
      puts "BALANCE: R$#{origin_account.balance}"
      puts '-------------------------------'
      puts 'PAYMENT METHOD'
      puts '1. PIX'
      puts '2. TED (1% tax)'
      print 'Enter the desired payment method number: '
      payment_method = gets.strip.to_i

      case payment_method
      when 1
        transfer.payment_method = 'PIX'

        puts '-------------------------------'
        puts 'PIX KEY TYPE'
        puts '1. CPF/CNPJ'
        puts '2. PHONE NUMBER'
        #TO-DO: Add random key option (each client can have up to 5 keys)
        # puts '3. Random key'
        print 'Enter the desired PIX key type number: '
        pix_key_type = gets.strip.to_i
        case pix_key_type
        when 1
          print 'Enter the destination client CPF/CNPJ: '
          document = gets.strip
          client = Client.find(document:)
          break puts 'No client with given document.' if client.nil?
          
          #Select Main Account of the destination client
          main_account = client.accounts.find{|account| account.name == 'Main Account'}
          transfer.destination_account_id = main_account.id 
        when 2
          puts 'ainda não dá pra fazer por telefone.'
          # print 'Enter the destination client phone (only numbers): '
          # phone = gets.strip
          # client = Client.find(phone:)
          # break puts 'No client with given document.' if client.nil?          
        else 
          break puts 'Invalid PIX key type.'
        end
      when 2
        puts 'ainda não dá pra fazer por TED.'
        # transfer.payment_method = 'TED'
        # puts '-------------------------------'
        #   print 'Enter the destination client full name: '
        #   name = gets.strip
        #   client = Client.find(name:)
        #   break puts 'No client with given name.' if client.nil?
          
        #   print 'Client CPF/CNPJ: '
        #   document = gets.strip
        #   client = Client.find(document:)
        #   break puts 'No client with given document.' if client.nil?
          
        #   print 'Account number (only numbers): '
        #   number = gets.strip
        #   account = Account.find(number:)
        #   break puts 'No account with given number' if account.nil?
      else
        break puts 'Invalid payment method.'
      end

      print "\nTransfer value: "
      amount = gets.strip.to_f

      break puts "The transfer value must be a number greater than 0." if amount <= 0
      break puts "The account balance is too low for the transfer\nTransfer canceled." if amount > origin_account.balance
      
      balance = origin_account.balance - amount
      origin_account.update(balance:)

      destination_account = Account.find(id: transfer.destination_account_id)
      balance = destination_account.balance + amount
      destination_account.update(balance:)
      
      transfer.amount = amount
      transfer.save
      print "Transfer of R$#{amount} "
      print "to '#{destination_account.name}' " 
      print "of #{destination_account.client.full_name} " 
      print "made successfully!"

      print "'#{origin_account.name} "
      print "of #{origin_account.client.full_name} "
      print "NEW BALANCE: R$#{origin_account.balance}"
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

