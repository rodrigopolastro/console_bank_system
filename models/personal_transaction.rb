class PersonalTransaction < Sequel::Model
  many_to_one :account
end