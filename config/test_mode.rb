# >>> IMPORTANT <<<
# In order to test the application quicker, feel free to set some of these
# constants as TRUE, so the script will auto-generate the specified values
# and skip input validations.
GENERATE_SAMPLE_DOCUMENT = true
GENERATE_SAMPLE_PHONE    = true
GENERATE_SAMPLE_ADRESS   = true

# You can also modify the sample values if needed

# SAMPLE CPF
sample_cpf = CPF.generate
while Client.find(document: sample_cpf)
  sample_cpf = CPF.generate
end
SAMPLE_CPF = sample_cpf

# SAMPLE CNPJ
sample_cnpj = CNPJ.generate
while Client.find(document: sample_cnpj)
  sample_cnpj = CNPJ.generate
end
SAMPLE_CNPJ = sample_cnpj

# SAMPLE ADRESS
SAMPLE_ADRESS = {
  federal_state: Faker::Address.state,
  city:          Faker::Address.city,
  district:      'Central District',
  public_area:   Faker::Address.street_name,
  postcode:      Faker::Address.postcode
}

# SAMPLE PHONE NUMBER
SAMPLE_PHONE = generate_phone_number

