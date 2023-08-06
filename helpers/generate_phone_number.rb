def generate_phone_number
  remove_phone_formatting(Faker::PhoneNumber.unique.cell_phone)
end

def format_phone(phone)
  phone.insert(0, "(")
       .insert(3, ")")
       .insert(4, " ")
       .insert(10, "-")
end

def remove_phone_formatting(phone)
  #Remove parenthesis, space and hyphen
  phone.delete("() -")
end