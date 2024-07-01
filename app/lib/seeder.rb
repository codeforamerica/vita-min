if Rails.env.production?
  # Avoid installing testing/time_helpers in production
  class Seeder; end
  return
end

require 'active_support/testing/time_helpers'

class Seeder
  include ActiveSupport::Testing::TimeHelpers

  def self.load_fraud_indicators
    return unless File.exist?('config/fraud_indicators.key')

    JSON.parse(Rails.application.encrypted('app/models/fraud/indicators.json.enc', key_path: 'config/fraud_indicators.key', env_key: 'FRAUD_INDICATORS_KEY').read).each do |indicator_attributes|
      indicator = Fraud::Indicator.find_or_initialize_by(name: indicator_attributes['name'])

      indicator.assign_attributes(
        indicator_attributes.merge(
          'activated_at' => Time.zone.now,
          'query_model_name' => indicator_attributes['query_model_name']&.constantize
        )
      )
      indicator.save!
    end
  end

  def run
    self.class.load_fraud_indicators

    Flipper.enable(:eitc)

    VitaProvider.find_or_initialize_by(name: "Public Library of the Seed Data").update(irs_id: "12345", coordinates: Geometry.coords_to_point(lat: 37.781707, lon: -122.408363), details: "972 Mission St\nSan Francisco, CA 94103\nAsk for help at the front desk\nFull Service\n415-555-1212")
    national_org = VitaPartner.find_or_create_by!(name: "GYR National Organization", type: Organization::TYPE)
    national_org.update(allows_greeters: true, national_overflow_location: true)

    ctc_org = VitaPartner.find_or_create_by!(name: "GetCTC.org", type: Organization::TYPE)
    VitaPartner.find_or_create_by!(name: "GetCTC.org (Site)", type: Site::TYPE, parent_organization: ctc_org)

    DefaultErrorMessages.generate!(service_type: :ctc)
    DefaultErrorMessages.generate!(service_type: :state_file)

    koalas = Coalition.find_or_create_by(name: "Koala Koalition")
    Coalition.find_or_create_by(name: "Cola Coalition")

    vp1 = first_org = VitaPartner.find_or_create_by!(
      name: "Oregano Org",
      coalition: koalas,
      type: Organization::TYPE
    )
    SourceParameter.find_or_create_by(code: "oregano", vita_partner_id: vp1.id)

    vp2 = VitaPartner.find_or_create_by!(
      name: "Orangutan Organization",
      coalition: koalas,
      type: Organization::TYPE
    )

    SourceParameter.find_or_create_by!(code: "orangutan", vita_partner_id: vp2.id)

    first_site = VitaPartner.find_or_create_by!(
      name: "Liberry Site",
      parent_organization: first_org,
      type: Site::TYPE,
      processes_ctc: true
    )

    SourceParameter.find_or_create_by!(code: "libeery", vita_partner_id: first_site.id)

    VitaPartnerZipCode.find_or_create_by!(
      zip_code: "94117",
      vita_partner: first_org,
    )

    VitaPartnerZipCode.find_or_create_by!(
      zip_code: "94016",
      vita_partner: first_site,
    )

    strong_shared_password = "vitavitavitavita"

    # organization lead user
    user = User.where(email: "skywalker@example.com").first_or_initialize
    user.update(
      name: "Luke Skywalker",
      password: strong_shared_password)
    user.update(role: OrganizationLeadRole.create(organization: first_org)) if user.role_type != OrganizationLeadRole::TYPE

    # site coordinator user
    user = User.where(email: "cucumber@example.com").first_or_initialize
    user.update(
      name: "Cindy Cucumber",
      password: strong_shared_password)
    user.update(role: SiteCoordinatorRole.create(sites: [first_site])) if user.role_type != SiteCoordinatorRole::TYPE

    # site team member user
    user = User.where(email: "melon@example.com").first_or_initialize
    user.update(
      name: "Marty Melon",
      password: strong_shared_password)
    user.update(role: TeamMemberRole.create(sites: [first_site])) if user.role_type != TeamMemberRole::TYPE

    # coalition lead user
    user = User.where(email: "lemon@example.com").first_or_initialize
    user.update(
      name: "Lola Lemon",
      password: strong_shared_password)
    user.update(role: CoalitionLeadRole.create(coalition: koalas)) if user.role_type != CoalitionLeadRole::TYPE

    # additional user
    additional_user = User.where(email: "princess@example.com").first_or_initialize
    additional_user.update(name: "Lea Amidala Organa", password: strong_shared_password)
    additional_user.update(role: OrganizationLeadRole.create(organization: first_org)) if additional_user.role_type != OrganizationLeadRole::TYPE

    if Rails.configuration.google_login_enabled
      pairs_file_data = YAML.safe_load(File.read(Rails.root.join(".pairs")))
      admin_names = pairs_file_data["pairs"]
      admin_emails = pairs_file_data["email_addresses"]
      admin_emails.each do |initials, email_address|
        admin_user = User.where(email: email_address).first_or_initialize
        admin_user.update(
          name: admin_names[initials],
          password: Devise.friendly_token[0, 20])
        admin_user.update(role: AdminRole.create(engineer: true, state_file: true)) if admin_user.role_type != AdminRole::TYPE
      end
    end

    admin_user = User.where(email: "admin@example.com").first_or_initialize
    admin_user.update(
      name: "Admin Amdapynurian",
      password: "theforcevita")
    admin_user.update(role: AdminRole.create(state_file: true)) if admin_user.role_type != AdminRole::TYPE

    greeter_user = User.where(email: "greeter@example.com").first_or_initialize
    greeter_user.update(
      name: "Greeter Greg (GYR Greeter)",
      password: strong_shared_password
    )

    greeter_user.update(role: GreeterRole.create) if greeter_user.role_type != GreeterRole::TYPE

    intake = find_or_create_intake_and_client(
      Intake::GyrIntake,
      primary_first_name: "Captain",
      primary_last_name: "Hook",
      sms_phone_number: "+14155551212",
      email_address: "crunch@example.com",
      primary_consented_to_service: "yes",
      sms_notification_opt_in: :yes,
      email_notification_opt_in: :yes,
      bank_name: "Self-help United",
      bank_routing_number: "011234567",
      bank_account_number: "87654321",
      bank_account_type: "checking",
      client_attributes: {
        vita_partner: first_org
      },
      tax_return_attributes: [
        { year: 2019, assigned_user: user, current_state: "intake_ready" },
        { year: 2018, current_state: "intake_ready" }
      ]
    )
    client = intake.client

    document1 = Document.find_or_initialize_by(display_name: "My Employment", document_type: "Employment", client: client, intake: intake)
    attach_upload_to_document(document1)
    document2 = Document.find_or_initialize_by(display_name: "Identity Document", document_type: "ID", client: client, intake: intake)
    attach_upload_to_document(document2)
    document3 = Document.find_or_initialize_by(display_name: "An old document type", document_type: "F13614C / F15080 2020", client: client, intake: intake)
    attach_upload_to_document(document3)

    unless client.outgoing_text_messages.present?
      OutgoingTextMessage.create!(client: client, body: "Hey client, nice to meet you", user: user, sent_at: 3.days.ago, to_phone_number: "+14155551212")
      OutgoingTextMessage.create!(client: client, body: "Hope you're having a good day", user: user, sent_at: 2.days.ago, to_phone_number: "+14155551212")
      OutgoingTextMessage.create!(client: client, body: "Thanks and have a good night!", user: user, sent_at: 1.day.ago, to_phone_number: "+14155551212")
    end

    unless client.incoming_text_messages.present?
      IncomingTextMessage.create!(client: client, body: "I am sending you some info.", received_at: 1.day.ago, from_phone_number: intake.sms_phone_number)
      IncomingTextMessage.create!(client: client, body: "What's up with my taxes?", received_at: DateTime.now, from_phone_number: "+14155551212")
    end

    unless client.notes.present?
      Note.create!(client: client, user: additional_user, body: "This is an incoming note!")
      Note.create!(client: client, user: user, body: "This is an outgoing note :)", created_at: 2.days.ago)
    end

    # Use this client for portal login; log in by email address & run rails jobs:work for the verification code; see SSN last 4 below
    _married_intake = find_or_create_intake_and_client(
      Intake::GyrIntake,
      primary_first_name: "Lucky",
      primary_last_name: "Charms",
      sms_phone_number: "+14155551212",
      primary_last_four_ssn: "1111",
      email_address: "charms@example.com",
      sms_notification_opt_in: :yes,
      email_notification_opt_in: :yes,
      filing_joint: "yes",
      spouse_first_name: "Marsha",
      spouse_last_name: "Charms",
      spouse_email_address: "justthemarshmallows@example.com",
      primary_consented_to_service: "yes",
      primary_consented_to_service_ip: "127.0.0.1",
      client_attributes: {
        vita_partner: first_org
      },
      tax_return_attributes: [
        { year: 2020, current_state: :prep_preparing }
      ]
    )

    recently_contacted_intake = find_or_create_intake_and_client(
      Intake::GyrIntake,
      primary_first_name: "RecentlyContacted",
      primary_last_name: "Smith",
      sms_phone_number: "+14155551213",
      tax_return_attributes: [
        { year: 2021 }
      ]
    )
    OutgoingTextMessage.find_or_initialize_by(client: recently_contacted_intake.client).update!(
      to_phone_number: recently_contacted_intake.sms_phone_number,
      sent_at: DateTime.now,
      body: "Hello there!"
    )

    travel_to 4.business_days.ago do
      approaching_sla_intake = find_or_create_intake_and_client(
        Intake::GyrIntake,
        primary_first_name: "NotSoRecentlyContacted",
        primary_last_name: "Smith",
        sms_phone_number: "+14155551214",
        tax_return_attributes: [
          { year: 2021 }
        ]
      )
      OutgoingTextMessage.find_or_initialize_by(client: approaching_sla_intake.client).update!(
        to_phone_number: recently_contacted_intake.sms_phone_number,
        sent_at: DateTime.now,
        body: "Hello there!"
      )
    end

    travel_to 10.business_days.ago do
      breached_sla_intake = find_or_create_intake_and_client(
        Intake::GyrIntake,
        primary_first_name: "LongAgoContacted",
        primary_last_name: "Smith",
        sms_phone_number: "+14155551214",
        tax_return_attributes: [
          { year: 2021 }
        ]
      )
      OutgoingTextMessage.find_or_initialize_by(client: breached_sla_intake.client).update!(
        to_phone_number: recently_contacted_intake.sms_phone_number,
        sent_at: DateTime.now,
        body: "Hello there!"
      )
    end

    intake_for_verification_attempt_1 = find_or_create_intake_and_client(
      Intake::CtcIntake,
      primary_first_name: "VerifierOne",
      primary_last_name: "Smith",
      primary_consented_to_service: "yes",
      product_year: 2022,
      tax_return_attributes: [{ year: 2021, current_state: "intake_ready", filing_status: "single" }],
    )

    va1_client = intake_for_verification_attempt_1.client
    efile_submission = va1_client.efile_submissions.last || va1_client.tax_returns.last.efile_submissions.create
    Fraud::Score.create_from(efile_submission) unless efile_submission.fraud_score.present?

    attempt = VerificationAttempt.find_or_initialize_by(client: va1_client) do |attempt|
      add_images_to_verification_attempt(attempt)
      attempt.save
    end
    attempt.transition_to(:pending)

    intake_for_verification_attempt_2 = find_or_create_intake_and_client(
      Intake::CtcIntake,
      primary_first_name: "VerifierTwo",
      primary_last_name: "Smith",
      primary_consented_to_service: "yes",
      product_year: 2022,
      tax_return_attributes: [{ year: 2021, current_state: "intake_ready", filing_status: "single" }],
    )
    va2_client = intake_for_verification_attempt_2.client
    efile_submission = va2_client.efile_submissions.last || va2_client.tax_returns.last.efile_submissions.create
    Fraud::Score.create_from(efile_submission) unless efile_submission.fraud_score.present?

    bypass_attempt = VerificationAttempt.find_or_initialize_by(client: va2_client) do |attempt|
      add_images_to_verification_attempt(attempt)
      attempt.save
    end
    bypass_attempt.transition_to(:pending)


    verifying_with_restricted_intake = find_or_create_intake_and_client(
        Intake::CtcIntake,
        primary_first_name: "RestrictedVerifier",
        primary_last_name: "Smith",
        primary_consented_to_service: "yes",
        product_year: 2022,
        tax_return_attributes: [{ year: 2021, current_state: "intake_ready", filing_status: "single" }],
    )

    verifying_with_restricted_intake.client.touch(:restricted_at)
    restricted_attempt = VerificationAttempt.find_or_initialize_by(client: verifying_with_restricted_intake.client) do |attempt|
      attempt.client_bypass_request = "I don't have an ID but I'd like to submit my taxes."
      add_images_to_verification_attempt(attempt)
      attempt.save
    end
    restricted_attempt.transition_to(:pending)

    eitc_under_twenty_four_qc = find_or_create_intake_and_client(
      Intake::CtcIntake,
      primary_first_name: "EitcUnderTwentyFourQC",
      primary_last_name: "Smith",
      primary_consented_to_service: "yes",
      primary_birth_date: 20.years.ago,
      claim_eitc: 'yes',
      exceeded_investment_income_limit: 'no',
      primary_tin_type: 'ssn',
      email_address: "yfong+EitcUnderTwentyFourQC@codeforamerica.org",
      email_address_verified_at: Time.current,
      product_year: 2022,
      tax_return_attributes: [{ year: 2021, current_state: "file_hold", filing_status: "single" }],
      dependent_attributes: [
        {
          first_name: "QC",
          last_name: "Smith",
          relationship: "niece",
          birth_date: 5.years.ago,
          full_time_student: "no",
          permanently_totally_disabled: "no",
          provided_over_half_own_support: "no",
          filed_joint_return: "no",
          months_in_home: 7,
          cant_be_claimed_by_other: "yes",
          claim_anyway: "yes",
          tin_type: "ssn",
          ssn: "123121234"
        }
      ],
      w2_attributes: [
        {
          employee: 'primary',
          employee_street_address: "456 Somewhere Ave",
          employee_city: "Cleveland",
          employee_state: "OH",
          employee_zip_code: "44092",
          employer_ein: "123456789",
          employer_name: "Code for America",
          employer_street_address: "123 Main St",
          employer_city: "San Francisco",
          employer_state: "CA",
          employer_zip_code: "94414",
          wages_amount: 100.10,
          federal_income_tax_withheld: 20.34,
        }
      ],
    )

    create_efile_security_info(eitc_under_twenty_four_qc.client) if eitc_under_twenty_four_qc.client.efile_security_informations.none?

    if eitc_under_twenty_four_qc.client.efile_submissions.none?
      eitc_under_twenty_four_qc_efile_submission = eitc_under_twenty_four_qc.client.tax_returns.last.efile_submissions.create
      eitc_under_twenty_four_qc_efile_submission.transition_to!(:preparing)
      eitc_under_twenty_four_qc_efile_submission.transition_to!(:queued)
      eitc_under_twenty_four_qc_efile_submission.transition_to!(:transmitted)
      eitc_under_twenty_four_qc_efile_submission.transition_to!(:rejected)
      efile_error = EfileError.create!(expose: true)
      eitc_under_twenty_four_qc_efile_submission.last_client_accessible_transition.efile_submission_transition_errors.create(efile_error: efile_error)
    end

    eitc_mfj_qc = find_or_create_intake_and_client(
      Intake::CtcIntake,
      primary_first_name: "EitcMFJQC",
      primary_last_name: "Smith",
      primary_consented_to_service: "yes",
      primary_birth_date: 35.years.ago,
      spouse_first_name: "Spouse",
      spouse_last_name: "Smith",
      spouse_birth_date: 35.years.ago,
      claim_eitc: 'yes',
      exceeded_investment_income_limit: 'no',
      primary_tin_type: 'ssn',
      email_address: "yfong+EitcMFJQC@codeforamerica.org",
      email_address_verified_at: Time.current,
      product_year: 2022,
      tax_return_attributes: [{ year: 2021, current_state: "file_hold", filing_status: "married_filing_jointly" }],
      dependent_attributes: [
        {
          first_name: "QC",
          last_name: "Smith",
          relationship: "niece",
          birth_date: 5.years.ago,
          full_time_student: "no",
          permanently_totally_disabled: "no",
          provided_over_half_own_support: "no",
          filed_joint_return: "no",
          months_in_home: 7,
          cant_be_claimed_by_other: "yes",
          claim_anyway: "yes",
          tin_type: "ssn",
          ssn: "123121234"
        }
      ],
      w2_attributes: [
        {
          employee: 'primary',
          employee_street_address: "456 Somewhere Ave",
          employee_city: "Cleveland",
          employee_state: "OH",
          employee_zip_code: "44092",
          employer_ein: "123456789",
          employer_name: "Code for America",
          employer_street_address: "123 Main St",
          employer_city: "San Francisco",
          employer_state: "CA",
          employer_zip_code: "94414",
          wages_amount: 100.10,
          federal_income_tax_withheld: 20.34,
        }
      ],
    )

    if eitc_mfj_qc.client.efile_submissions.none?
      eitc_mfj_qc_efile_submission = eitc_mfj_qc.client.tax_returns.last.efile_submissions.create
      eitc_mfj_qc_efile_submission.transition_to!(:preparing)
      eitc_mfj_qc_efile_submission.transition_to!(:queued)
      eitc_mfj_qc_efile_submission.transition_to!(:transmitted)
      eitc_mfj_qc_efile_submission.transition_to!(:rejected)
      efile_error = EfileError.create!(expose: true, auto_cancel: false, code: 'not-auto-cancel', message: 'this is an error that is not auto cancel')
      auto_cancel_efile_error = EfileError.create!(expose: true, auto_cancel: true, code: 'auto-cancel', message: 'this is an error that is auto cancel')
      eitc_mfj_qc_efile_submission.last_client_accessible_transition.efile_submission_transition_errors.create(efile_error: efile_error)
      eitc_mfj_qc_efile_submission.last_client_accessible_transition.efile_submission_transition_errors.create(efile_error: auto_cancel_efile_error)
    end

    find_or_create_intake_and_client(
      Intake::CtcIntake,
      product_year: 2022,
      primary_first_name: "EitcNoQC",
      primary_last_name: "Smith",
      primary_consented_to_service: "yes",
      primary_birth_date: 35.years.ago,
      claim_eitc: 'yes',
      exceeded_investment_income_limit: 'no',
      primary_tin_type: 'ssn',
      email_address: "yfong+EitcNoQC@codeforamerica.org",
      email_address_verified_at: Time.current,
      current_step: "/en/questions/w2s",
      tax_return_attributes: [{ year: 2021, current_state: "intake_in_progress", filing_status: "single" }],
      w2_attributes: [
        {
          employee: 'primary',
          employee_street_address: "456 Somewhere Ave",
          employee_city: "Cleveland",
          employee_state: "OH",
          employee_zip_code: "44092",
          employer_ein: "123456789",
          employer_name: "Code for America",
          employer_street_address: "123 Main St",
          employer_city: "San Francisco",
          employer_state: "CA",
          employer_zip_code: "94414",
          wages_amount: 100.10,
          federal_income_tax_withheld: 20.34,
        }
      ],
    )

    find_or_create_intake_and_client(
      Archived::Intake::GyrIntake2021,
      primary_first_name: "ArchivedGyr2021",
      primary_last_name: "Adams",
      primary_consented_to_service: "yes",
      primary_birth_date: 75.years.ago,
      primary_tin_type: 'ssn',
      email_address: "archived2021@example.com",
      email_address_verified_at: Time.current,
      tax_return_attributes: [{ year: 2021, current_state: "intake_in_progress", filing_status: "single" }],
    )

    find_or_create_intake_and_client(
      Intake::GyrIntake,
      product_year: 2022,
      primary_first_name: "GyrPy2022",
      primary_last_name: "Bingocard",
      primary_consented_to_service: "yes",
      primary_birth_date: 75.years.ago,
      primary_tin_type: 'ssn',
      email_address: "archived2022@example.com",
      email_address_verified_at: Time.current,
      tax_return_attributes: [{ year: 2021, current_state: "intake_in_progress", filing_status: "single" }],
    )

    Fraud::Indicators::Timezone.create(name: "America/Chicago", activated_at: DateTime.now)
    Fraud::Indicators::Timezone.create(name: "America/Indiana/Indianapolis", activated_at: DateTime.now)
    Fraud::Indicators::Timezone.create(name: "America/Indianapolis", activated_at: DateTime.now)
    Fraud::Indicators::Timezone.create(name: "Mexico/Tijuana", activated_at: nil)
    Fraud::Indicators::Timezone.create(name: "America/New_York", activated_at: DateTime.now)
    Fraud::Indicators::Timezone.create(name: "America/Los_Angeles", activated_at: DateTime.now)
    SearchIndexer.refresh_search_index

    state_file_arizona_intake = StateFileAzIntake.find_or_create_by!(
      primary_first_name: "Ari",
      primary_last_name: "Zona",
      consented_to_terms_and_conditions: "yes",
      primary_birth_date: 35.years.ago,
      email_address: "ari.zona@example.com",
      federal_submission_id: "12345202201011232170",
      email_address_verified_at: Time.current
    )

    if state_file_arizona_intake.efile_submissions.none?
      efile_submission = EfileSubmission.find_or_create_by!(
        irs_submission_id: "9999992021199yrv4rab",
        data_source: state_file_arizona_intake,
      )
      efile_submission.transition_to!(:preparing)
      efile_submission.transition_to!(:queued)
      efile_submission.transition_to!(:transmitted)
    end
  end

  def find_or_create_intake_and_client(intake_type, attributes)
    attributes[:preferred_name] = attributes[:primary_first_name] if attributes[:preferred_name].blank?
    attributes[:product_year] = Rails.configuration.product_year if attributes[:product_year].blank? && !intake_type.ancestors.include?(Archived::Intake2021)

    attributes[:visitor_id] = SecureRandom.hex(26)

    finder_columns = [:primary_first_name, :primary_last_name, :preferred_name]
    finder_attributes = attributes.slice(*finder_columns)
    if finder_attributes.blank?
      raise "Seeder must provide at least one of (#{finder_columns.join(', ')}) when making an intake"
    end

    intake = intake_type.find_by(finder_attributes) || intake_type.new(finder_attributes)
    return intake if intake.persisted?

    client_attributes = attributes.delete(:client_attributes)
    unless intake.client
      intake.client = Client.new(client_attributes)
    end

    tax_return_attributes = attributes.delete(:tax_return_attributes)
    dependent_attributes = attributes.delete(:dependent_attributes)
    w2_attributes = attributes.delete(:w2_attributes)
    intake.update!(attributes)

    unless intake.tax_returns.present?
      tax_return_attributes.each do |tax_year_attributes|
        status = tax_year_attributes.delete(:current_state) || "intake_ready"
        tax_return = intake.client.tax_returns.create(tax_year_attributes)
        tax_return.transition_to!(status)
      end
    end

    unless intake.dependents.present?
      dependent_attributes&.each do |da|
        intake.dependents.create!(da)
      end
    end

    unless intake_type.ancestors.include?(Archived::Intake2021)
      unless intake.w2s_including_incomplete.present?
        w2_attributes&.each do |w2|
          intake.w2s_including_incomplete.create!(w2)
        end
      end
    end

    intake
  end

  def attach_upload_to_document(document)
    document.upload.attach(
      io: File.open(Rails.root.join("spec", "fixtures", "files", "document_bundle.pdf")),
      filename: "document_bundle.pdf"
    ) unless document.upload.present?
    document.save
  end

  def add_images_to_verification_attempt(verification_attempt)
    verification_attempt.selfie.attach(
      io: File.open(Rails.root.join("spec", "fixtures", "files", "picture_id.jpg")),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    ) unless verification_attempt.selfie.present?
    verification_attempt.photo_identification.attach(
      io: File.open(Rails.root.join("spec", "fixtures", "files", "picture_id.jpg")),
      filename: 'test.jpg',
      content_type: 'image/jpeg'
    ) unless verification_attempt.photo_identification.present?
  end

  def create_efile_security_info(client)
    return unless client.efile_security_informations.count < 2

    efile_security_info_params = {
      device_id: "AA" * 20,
      user_agent: "Mozilla/5.0 (iPhone)",
      browser_language: "en-US",
      platform: "iPhone",
      timezone_offset: "+300",
      ip_address: "72.34.67.178",
      recaptcha_score: 0.9e0,
      timezone: "America/New_York",
      client_system_time: DateTime.now
    }
    client.efile_security_informations.create(efile_security_info_params)
  end
end
