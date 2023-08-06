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
  federal_state: 'XX',
  city: 'Sample City',
  district: 'Sample District',
  public_area: 'Sample Public_area',
  zipcode: '55555333'
}

# SAMPLE PHONE NUMBER
SAMPLE_PHONE = '19911112222'

