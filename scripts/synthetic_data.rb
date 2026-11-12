# Usage:
#     ruby synthetic_data.rb data.jsonl
# When jsonl file is in complex format, use `complex` flag:
#     ruby synthetic_data.rb complex_data.jsonl complex
# (Uses Senzing-style JSONL files.)
# To generate N clients from built-in name lists (no input file needed):
#     ruby synthetic_data.rb generate 5000
#
# Every generated client is "enriched" so the hub clients page has realistic per-row work:
# a vita partner, locale / interview language / navigator variety, joint filers, dependents,
# documents, a prior-year return for some clients, assigned users, messages, and flags.
# Messages and documents are bulk inserted, so no Twilio/Mailgun/screener callbacks fire.
# Set ENRICH=0 to get the original bare-bones behavior.

require_relative '../config/environment'

ENRICH = ENV.fetch('ENRICH', '1') != '0'
BATCH_SIZE = 250

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

FIRST_NAMES = %w[Maria Jose Juan Ana Luis Carmen James Mary Robert Patricia Michael Jennifer David Linda William
                 Elizabeth Nguyen Mai Wei Li Fatima Ahmed Aisha Omar Grace Daniel Sofia Mateo Valentina Diego
                 Camila Lucas Isabella Ethan Olivia Noah Emma Liam Ava Mia].freeze
LAST_NAMES = %w[Garcia Rodriguez Martinez Hernandez Lopez Gonzalez Smith Johnson Williams Brown Jones Miller Davis
                Wilson Anderson Thomas Taylor Moore Jackson Martin Lee Nguyen Tran Pham Chen Wang Kim Park Patel
                Khan Ali Hassan Rivera Torres Flores Ramirez Cruz Reyes Morales Ortiz].freeze

COMMON_DOCUMENT_TYPES = ["Drivers License", "State ID", "Passport", "SSN or ITIN", "W2", "1099-INT", "1099-G",
                         "1098-T", "1095-A", "Prior Year Tax Return", "Other"].freeze

def read_file(fname)
  # Returns array of hashes.
  # Note: not all rows will have the same set of keys.
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
  type = params[:filing_joint] ? :married_filing_jointly : :single
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
  }.merge(params.fetch(:extra_intake_attributes, {}))
  client = Client.create(
    consented_to_service_at: Time.zone.now,
    vita_partner_id: params[:vita_partner_id],
    intake_attributes: intake_attributes,
    tax_returns_attributes: [{ year: MultiTenantService.new(:gyr).current_tax_year, is_ctc: false }],
  )
  unless client.valid?
    raise 'client record not valid?'
  end

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
    if params[:dependent_count].to_i != 1
      client.intake.dependents.create(default_attributes.merge(
        first_name: 'Relly',
        last_name: last_name,
        relationship: %w[aunt uncle].sample,
        birth_date: 52.years.ago,
      ))
    end
  end
  client.intake
end

# Distribution knobs for enrichment. Rough guesses at production shape; tune as Datadog/Metabase data comes in.
def enrichment_params
  return {} unless ENRICH

  locale = rand < 0.7 ? 'en' : 'es'
  interview_language = rand < 0.9 ? locale : %w[vi zh ru ar].sample
  navigators = %w[general incarcerated limited_english unhoused].to_h do |kind|
    ["with_#{kind}_navigator".to_sym, rand < 0.05]
  end
  dependents_roll = rand
  {
    vita_partner_id: $vita_partner_ids.sample,
    filing_joint: rand < 0.25,
    with_dependents: dependents_roll < 0.4 ? 'yes' : 'no',
    dependent_count: dependents_roll < 0.2 ? 1 : 2,
    extra_intake_attributes: {
      locale: locale,
      preferred_interview_language: interview_language,
    }.merge(navigators),
  }
end

# Adds the things the hub clients page touches per row: prior-year returns, assignees, documents,
# messages, flags and spread-out timestamps. Bulk rows are collected in `pending` and flushed per batch.
def enrich_client(intake, pending)
  client = intake.client
  created_at = rand(1..180).days.ago - rand(0..86_400).seconds
  client.update_columns(created_at: created_at, consented_to_service_at: created_at)
  intake.update_columns(created_at: created_at, vita_partner_id: client.vita_partner_id)

  if rand < 0.3
    prior_year = client.tax_returns.create!(year: MultiTenantService.new(:gyr).current_tax_year - 1, service_type: 'online_intake')
    prior_year.advance_to(:file_accepted)
  end

  eligible_assignees = $assignees_by_partner_id.fetch(client.vita_partner_id, [])
  client.tax_returns.reload.each do |tax_return|
    next unless eligible_assignees.any? && rand < 0.6

    tax_return.update_columns(assigned_user_id: eligible_assignees.sample)
  end

  rand(0..6).times do
    pending[:documents] << {
      client_id: client.id, intake_id: intake.id, document_type: COMMON_DOCUMENT_TYPES.sample,
      display_name: 'picture_id.jpg', created_at: created_at, updated_at: created_at
    }
  end

  last_outgoing = nil
  last_incoming = nil
  rand(0..8).times do
    sent_at = created_at + rand(0..((Time.current - created_at).to_i)).seconds
    timestamps = { client_id: client.id, created_at: sent_at, updated_at: sent_at }
    case rand(5)
    when 0
      pending[:outgoing_text_messages] << timestamps.merge(body: 'Hi, this is your tax preparer.', to_phone_number: '+14155550100', twilio_status: 'delivered', sent_at: sent_at, user_id: eligible_assignees.sample)
      last_outgoing = [last_outgoing, sent_at].compact.max
    when 1
      pending[:outgoing_emails] << timestamps.merge(body: 'Please upload your W-2.', subject: 'Update from GetYourRefund', to: intake.email_address, mailgun_status: 'delivered', sent_at: sent_at, user_id: eligible_assignees.sample)
      last_outgoing = [last_outgoing, sent_at].compact.max
    when 2
      pending[:incoming_text_messages] << timestamps.merge(body: 'Thanks, I uploaded it.', from_phone_number: '+14155550100', received_at: sent_at)
      last_incoming = [last_incoming, sent_at].compact.max
    when 3
      pending[:incoming_emails] << timestamps.merge(body_plain: 'When will my return be filed?', from: intake.email_address, recipient: 'hello@getyourrefund.org', sender: intake.email_address, received_at: sent_at)
      last_incoming = [last_incoming, sent_at].compact.max
    when 4
      pending[:incoming_portal_messages] << timestamps.merge(body: 'I have a question about my documents.')
      last_incoming = [last_incoming, sent_at].compact.max
    end
  end

  client.update_columns(
    last_outgoing_communication_at: last_outgoing,
    first_unanswered_incoming_interaction_at: (last_incoming if last_incoming && (last_outgoing.nil? || last_incoming > last_outgoing)),
    flagged_at: (created_at if rand < 0.05),
    updated_at: [created_at, last_outgoing, last_incoming].compact.max,
  )
  pending[:client_ids] << client.id
end

def flush_pending(pending)
  if pending[:documents].any?
    document_ids = Document.insert_all(pending[:documents], returning: [:id]).rows.flatten
    ActiveStorage::Attachment.insert_all(document_ids.map do |id|
      { name: 'upload', record_type: 'Document', record_id: id, blob_id: $shared_blob.id, created_at: Time.current }
    end)
  end
  OutgoingTextMessage.insert_all(pending[:outgoing_text_messages]) if pending[:outgoing_text_messages].any?
  OutgoingEmail.insert_all(pending[:outgoing_emails]) if pending[:outgoing_emails].any?
  IncomingTextMessage.insert_all(pending[:incoming_text_messages]) if pending[:incoming_text_messages].any?
  IncomingEmail.insert_all(pending[:incoming_emails]) if pending[:incoming_emails].any?
  IncomingPortalMessage.insert_all(pending[:incoming_portal_messages]) if pending[:incoming_portal_messages].any?
  # Bulk inserts skip callbacks, so recompute the denormalized filter columns the hub filters on.
  SearchIndexer.refresh_filterable_properties(pending[:client_ids]) if pending[:client_ids].any?
  new_pending
end

def new_pending
  Hash.new { |h, k| h[k] = [] }
end

def setup_enrichment
  return unless ENRICH

  $vita_partner_ids = VitaPartner.pluck(:id)
  raise 'No vita partners found; run `bin/rails db:seed` first' if $vita_partner_ids.empty?

  $assignees_by_partner_id = Hash.new { |h, k| h[k] = [] }
  User.where(role_type: [TeamMemberRole::TYPE, SiteCoordinatorRole::TYPE, OrganizationLeadRole::TYPE, AdminRole::TYPE]).find_each do |user|
    user.accessible_vita_partners.pluck(:id).each { |id| $assignees_by_partner_id[id] << user.id }
  end

  $shared_blob = ActiveStorage::Blob.create_and_upload!(
    io: File.open(Rails.root.join('spec/fixtures/files/picture_id.jpg')),
    filename: 'picture_id.jpg',
    content_type: 'image/jpeg'
  )
end

def rows_from_args
  if ARGV[0] == 'generate'
    Integer(ARGV[1] || 1000).times.map do
      { first: FIRST_NAMES.sample, last: LAST_NAMES.sample }
    end
  else
    read_file(ARGV[0]).map do |row|
      first = ARGV[1] == 'complex' ? row['FEATURES'][1]['NAME_FIRST'] : row['PRIMARY_NAME_FIRST']
      last = ARGV[1] == 'complex' ? row['FEATURES'][1]['NAME_LAST'] : row['PRIMARY_NAME_LAST']
      { first: first, last: last }
    end
  end
end

def main
  puts "Rails.env = " + Rails.env
  puts "Initial client record tally: " + get_client_count.to_s
  setup_enrichment

  pending = new_pending
  created = 0
  rows_from_args.each do |row|
    first = row[:first]
    last = row[:last]
    next unless first.present? && last.present?

    new_intake = generate_gyr_intake({
      first_name: first,
      last_name: last,
      sms_phone_number: ENRICH ? "+1415555#{rand(1000..9999)}" : nil,
      email_address: "testuser+#{SecureRandom.hex(6)}@example.example",
      with_dependents: 'no',
      state_of_residence: rand_state_of_residence}.merge(enrichment_params))

    # Randomly pick stage/status of intake:
    new_intake.tax_returns.each do |tax_return|
      tax_return.advance_to(rand_intake_stage)
    end

    # Note: alternate method of advancing stage, e.g.:
    # client.tax_returns.last.transition_to!(:intake_in_progress)

    enrich_client(new_intake, pending) if ENRICH
    created += 1
    if created % BATCH_SIZE == 0
      pending = flush_pending(pending) if ENRICH
      puts "#{created} clients created @ #{Time.now}"
    end
  end
  flush_pending(pending) if ENRICH

  # Intake saves only mark searchable_data as stale; build the tsvectors so hub search works.
  SearchIndexer.refresh_search_index while Intake.where.not(needs_to_flush_searchable_data_set_at: nil).exists?

  puts "Concluding client record tally: " + get_client_count.to_s
end

main()
