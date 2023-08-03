class Transfer < Sequel::Model
  many_to_one :origin_account,      class: :Account
  many_to_one :destination_account, class: :Account
end
