# Usage:
#     ruby synthetic_data.rb data.jsonl
# When jsonl file is in complex format, use `complex` flag:
#     ruby synthetic_data.rb complex_data.jsonl complex

require_relative '../config/environment'

def get_client_count
  Client.count
end

$states_keys = States.keys
$states_count = States.keys.size

def rand_state_of_residence
  $states_keys[Random.rand($states_count)]
end

$intake_stages = TaxReturnStateMachine.states.map(&:to_sym)
$intake_stages_count = TaxReturnStateMachine.states.size

def rand_intake_stage
  $intake_stages[Random.rand($intake_stages_count)]
rescue ArgumentError
  :intake_needs_doc_help 
end 

$test_intake = {
  first_name: 'Testuser',
  last_name: 'Testuser',
  sms_phone_number: nil,
  email_address: "testuser+#{Time.now.to_i.to_s(36)}@example.example",
  with_dependents: 'no',
  state_of_residence: rand_state_of_residence}

def read_file(fname)
  # Returns array of hashes.
  # Note: not all rows will hae the smae set of keys.
  sio = StringIO.new
  File.open(fname) { |f|
    f.each_line { |line| sio << line } }
  sio.string.split("\n").map do |line|
    h = JSON.parse(line)
    h.default = '' # Some rows might be missing fields
    h
  end 
end

# Slightly modified version of what's in app/controllers/flow_controller.rb 
def generate_gyr_intake(params)
  type = :single
  first_name = params[:first_name]
  last_name = params[:last_name]
  sms_phone_number = PhoneParser.normalize(params[:sms_phone_number])
  email_address = params[:email_address]
  with_dependents = params[:with_dependents] == 'yes'

  intake_attributes = {
    type: Intake::GyrIntake.to_s,
    product_year: Rails.configuration.product_year,
    visitor_id: SecureRandom.hex(26),
    filed_prior_tax_year: 'did_not_file',
    primary_birth_date: 30.years.ago,
    primary_tin_type: 'ssn',
    primary_ssn: '555112222',
    primary_last_four_ssn: '2222',
    primary_first_name: first_name,
    primary_last_name: last_name,
    preferred_name: "#{first_name} #{last_name}",
    sms_phone_number: sms_phone_number.presence,
    email_address: email_address.presence,
    email_address_verified_at: (
      email_address.present? & email_address&.end_with?('@example.example')) ?
      DateTime.now :
      nil,
    eip1_amount_received: 0,
    eip2_amount_received: 0,
    street_address: '123 Main St',
    city: 'Los Angeles',
    state: 'CA',
    zip_code: '90210',
    filing_joint: 'no',
    current_step: Questions::MailingAddressController.to_path_helper,

    # Assign random state of residence.
    state_of_residence: params[:state_of_residence]
  }
  client = Client.create(
    consented_to_service_at: Time.zone.now,
    intake_attributes: intake_attributes,
    tax_returns_attributes: [{ year: MultiTenantService.new(:gyr).current_tax_year, is_ctc: false }],
  )
  unless client.valid?
    raise 'client record not valid?'
    # return
  end

  # client.tax_returns.last.transition_to!(:intake_in_progress)

  if type == :married_filing_jointly
    client.intake.update(
      spouse_birth_date: 31.years.ago + 51.days,
      spouse_last_four_ssn: '3333',
      spouse_first_name: "#{first_name} Spouse",
      spouse_last_name: last_name,
      filing_joint: 'yes',
    )
  end

  if with_dependents
    client.intake.update(
      had_dependents: 'yes'
    )
    default_attributes = {
      months_in_home: 12,
      us_citizen: 'yes',
      was_married: 'no',
      was_student: 'no',
      north_american_resident: 'no',
      disabled: 'no',
    }
    client.intake.dependents.create(default_attributes.merge(
      first_name: 'Childy',
      last_name: last_name,
      relationship: %w[son daughter].sample,
      birth_date: 12.years.ago,
    ))
    client.intake.dependents.create(default_attributes.merge(
      first_name: 'Relly',
      last_name: last_name,
      relationship: %w[aunt uncle].sample,
      birth_date: 52.years.ago,
    ))
  end
  client.intake
end

def main
  puts "Rails.env = " + Rails.env
  puts "Initial client record tally: " + get_client_count.to_s

  data = read_file(ARGV[0])

  data.each do |row|
    first = ARGV[1] == 'complex' ? row['FEATURES'][1]['NAME_FIRST'] : row['PRIMARY_NAME_FIRST']
    last = ARGV[1] == 'complex' ? row['FEATURES'][1]['NAME_LAST'] : row['PRIMARY_NAME_LAST']
    if first and last
      p 'New intake (' + first + ' ' + last + ') @ ' + Time.now.to_s
      new_intake = generate_gyr_intake({
        first_name: first,
        last_name: last,
        sms_phone_number: nil,
        email_address: "testuser+#{Time.now.to_i.to_s(36)}@example.example",
        with_dependents: 'no',
        state_of_residence: rand_state_of_residence})

      # Randomly pick stage/status of intake:
      new_intake.tax_returns.each do |tax_return|
        tax_return.advance_to(rand_intake_stage)
      end
    end
  end

  puts "Concluding client record tally: " + get_client_count.to_s
end

main()
