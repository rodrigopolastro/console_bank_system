class Account < Sequel::Model
  many_to_one :client

  one_to_many :personal_transactions

  one_to_many :transfers_made,     class: :Transfer, key: :origin_account_id
  one_to_many :transfers_received, class: :Transfer, key: :destination_account_id

  def self.list_accounts
    puts 'NATURAL PERSONS ACCOUNTS'
    natural_persons = Client.where(document_type: 'CPF').all
  
    natural_persons.each do |natural_person|
      cpf = CPF.new(natural_person.document)
      puts "\n#{natural_person.full_name} - CPF: #{cpf.formatted}"
  
      natural_person.accounts.each do |account|
        puts " -> #{account.number.insert(4, '-')} - #{account.name}"
      end
    end
    puts '-------------------------------'
    puts 'LEGAL PERSONS ACCOUNTS'
    legal_persons   = Client.where(document_type: 'CNPJ').all
  
    legal_persons.each do |legal_person|
      cnpj = CNPJ.new(legal_person.document)
      puts "\n#{legal_person.full_name} - CNPJ: #{cnpj.formatted}"
  
      legal_person.accounts.each do |account|
        puts " -> #{account.number.insert(4, '-')} - #{account.name}"
      end
    end
  end

  def self.find_or_list_accounts
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
  end

  def self.show_account_balance(account)
    puts "Account #{account.number.insert(4, '-')} - #{account.name} of #{account.client.full_name}"
    puts "BALANCE: R$#{account.balance}"
  end

  def deposits
    personal_transactions.select{|t| t.transaction_type == 'deposit'}
  end

  def withdrawals
    personal_transactions.select{|t| t.transaction_type == 'deposit'}
  end

  def deposits_sum
    deposits.sum{|d| d.amount}
  end

  def withdrawals_sum
    withdrawals.sum{|w| w.amount}
  end

  def transfers_made_sum
    transfers_made.sum{|tm| tm.amount}
  end

  def transfers_received_sum
    transfers_received.sum{|tr| tr.amount}
  end
end