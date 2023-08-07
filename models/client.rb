class Client < Sequel::Model
  one_to_many :accounts

  #TO-DO: Show more info about client
  def self.list_clients 
    puts 'NATURAL PERSONS'
    natural_persons = Client.where(document_type: 'CPF').all

    natural_persons.each do |natural_person|
      cpf = CPF.new(natural_person.document)
      #TO-DO: set a 50 length space (max size name) here to display cpfs aligned
      puts "\n#{natural_person.full_name} - CPF: #{cpf.formatted}"
      puts " -> Client since: #{natural_person.created_at}"
      phone = natural_person.phone.clone
      puts " -> Phone: #{format_phone(phone)}"
      puts " -> Adress: #{full_address(natural_person)}"
    end
    puts '-------------------------------'
    puts 'LEGAL PERSONS'
    legal_persons   = Client.where(document_type: 'CNPJ').all

    legal_persons.each do |legal_person|
      cnpj = CNPJ.new(legal_person.document)
      puts "#{legal_person.full_name} - CNPJ: #{cnpj.formatted}"
    end
  end

  private  

  def self.full_address(client)
    "#{client.public_area},  #{client.district} - #{client.postcode} - #{client.city}/#{client.federal_state}"
  end
end