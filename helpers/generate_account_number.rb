# All the accounts are identified by a 8 digit number.
#
# This number is formed by account_id preceded by its respective client_id and a hyphen. 
# Both ID's have as many leading zeros as necessary to form 4 digit numbers
#
# Ex: account_id = 125, client_id = 70
#    acconut_number => '0070-0125'
#
# IMPORTANT:
# This way, the bank only supports formatting for 9999 clients and accounts, 
# but this could be easily expanded by increasing the number 4 in the method
def generate_account_number(account)
  account_number = ""

  def leading_zeros(id)
    standard_id = ""

    zeros_to_add = 4 - id.to_s.size
    zeros_to_add.times do
      standard_id += "0"
    end 

    standard_id += id.to_s
  end

  account_number = leading_zeros(account.client_id) + leading_zeros(account.id)
end



