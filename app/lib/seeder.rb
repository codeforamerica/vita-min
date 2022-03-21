if Rails.env.production?
  # Avoid installing testing/time_helpers in production
  class Seeder; end
  return
end

require 'active_support/testing/time_helpers'

class Seeder
  include ActiveSupport::Testing::TimeHelpers

  def run
    national_org = VitaPartner.find_or_create_by!(name: "GYR National Organization", type: Organization::TYPE)
    national_org.update(allows_greeters: true, national_overflow_location: true)

    ctc_org = VitaPartner.find_or_create_by!(name: "GetCTC.org", type: Organization::TYPE)
    VitaPartner.find_or_create_by!(name: "GetCTC.org (Site)", type: Site::TYPE, parent_organization: ctc_org)

    DefaultErrorMessages.generate!

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

    # organization lead user
    user = User.where(email: "skywalker@example.com").first_or_initialize
    user.update(
      name: "Luke Skywalker",
      password: "theforcevita")
    user.update(role: OrganizationLeadRole.create(organization: first_org)) if user.role_type != OrganizationLeadRole::TYPE

    # site coordinator user
    user = User.where(email: "cucumber@example.com").first_or_initialize
    user.update(
      name: "Cindy Cucumber",
      password: "theforcevita")
    user.update(role: SiteCoordinatorRole.create(site: first_site)) if user.role_type != SiteCoordinatorRole::TYPE

    # site team member user
    user = User.where(email: "melon@example.com").first_or_initialize
    user.update(
      name: "Marty Melon",
      password: "theforcevita")
    user.update(role: TeamMemberRole.create(site: first_site)) if user.role_type != TeamMemberRole::TYPE

    # coalition lead user
    user = User.where(email: "lemon@example.com").first_or_initialize
    user.update(
      name: "Lola Lemon",
      password: "theforcevita")
    user.update(role: CoalitionLeadRole.create(coalition: koalas)) if user.role_type != CoalitionLeadRole::TYPE

    # additional user
    additional_user = User.where(email: "princess@example.com").first_or_initialize
    additional_user.update(
      name: "Lea Amidala Organa",
      password: "theforcevita")
    additional_user.update(role: OrganizationLeadRole.create(organization: first_org)) if additional_user.role_type != OrganizationLeadRole::TYPE

    admin_user = User.where(email: "admin@example.com").first_or_initialize
    admin_user.update(
      name: "Admin Amdapynurian",
      password: "theforcevita")
    admin_user.update(role: AdminRole.create) if admin_user.role_type != AdminRole::TYPE

    greeter_user = User.where(email: "greeter@example.com").first_or_initialize
    greeter_user.update(
      name: "Greeter Greg (GYR Greeter)",
      password: "theforcevita"
    )

    greeter_user.update(role: GreeterRole.create) if greeter_user.role_type != GreeterRole::TYPE

    intake = find_or_create_intake_and_client(
      Intake::GyrIntake,
      primary_first_name: "Captain",
      primary_last_name: "Hook",
      sms_phone_number: "+14155551212",
      email_address: "crunch@example.com",
      primary_consented_to_service_at: DateTime.current,
      sms_notification_opt_in: :yes,
      email_notification_opt_in: :yes,
      bank_name: "Self-help United",
      bank_routing_number: "12345678",
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

    Document.find_or_create_by(display_name: "My Employment", document_type: "Employment", client: client, created_at: 1.day.ago, intake: intake)
    Document.find_or_create_by(display_name: "Identity Document", document_type: "ID", client: client, created_at: 2.months.ago, intake: intake)

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
      primary_consented_to_service_at: DateTime.current,
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

    verifying_no_bypass_yet_intake = find_or_create_intake_and_client(
      Intake::CtcIntake,
      primary_first_name: "VerifierOne",
      primary_last_name: "Smith",
      primary_consented_to_service_at: DateTime.current,
      tax_return_attributes: [{ year: 2021, current_state: "intake_ready" }],
    )
    VerificationAttempt.find_or_initialize_by(client: verifying_no_bypass_yet_intake.client) do |attempt|
      add_images_to_verification_attempt(attempt)
      attempt.save
    end

    verifying_with_bypass_intake = find_or_create_intake_and_client(
      Intake::CtcIntake,
      primary_first_name: "VerifierTwo",
      primary_last_name: "Smith",
      primary_consented_to_service_at: DateTime.current,
      tax_return_attributes: [{ year: 2021, current_state: "intake_ready" }],
    )
    VerificationAttempt.find_or_initialize_by(client: verifying_with_bypass_intake.client) do |attempt|
      attempt.client_bypass_request = "I don't have an ID but I'd like to submit my taxes."
      add_images_to_verification_attempt(attempt)
      attempt.save
    end
  end

  def find_or_create_intake_and_client(intake_type, attributes)
    attributes[:preferred_name] = attributes[:primary_first_name] if attributes[:preferred_name].blank?
    attributes[:visitor_id] = SecureRandom.hex(26)

    finder_columns = [:primary_first_name, :primary_last_name, :preferred_name]
    finder_attributes = attributes.slice(*finder_columns)
    if finder_attributes.blank?
      raise "Seeder must provide at least one of (#{finder_columns.join(', ')}) when making an intake"
    end

    intake = intake_type.find_or_initialize_by(finder_attributes)
    return intake if intake.persisted?

    client_attributes = attributes.delete(:client_attributes)
    unless intake.client
      intake.client = Client.new(client_attributes)
    end

    tax_return_attributes = attributes.delete(:tax_return_attributes)
    intake.update!(attributes)
    unless intake.tax_returns.present?
      tax_return_attributes.each do |tax_year_attributes|
        status = tax_year_attributes.delete(:current_state) || "intake_ready"
        tax_return = intake.client.tax_returns.create(tax_year_attributes)
        tax_return.transition_to!(status)
      end
    end

    intake
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
end
