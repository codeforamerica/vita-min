# Create client_support_org if needed
national_org = VitaPartner.find_or_create_by!(name: "GYR National Organization", type: Organization::TYPE)
national_org.update(allows_greeters: true, national_overflow_location: true)

# Create GetCTC.org org if needed
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

SourceParameter.find_or_create_by(code: "orangutan", vita_partner_id: vp2.id)

first_site = VitaPartner.find_or_create_by!(
  name: "Liberry Site",
  parent_organization: first_org,
  type: Site::TYPE,
  processes_ctc: true
)

SourceParameter.find_or_create_by(code: "libeery", vita_partner_id: first_site.id)

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

client = Client.find_or_create_by(vita_partner: first_org)

intake = Intake::GyrIntake.create(
  client: client,
  preferred_name: "Captain",
  primary_first_name: "Captain",
  primary_last_name: "Hook",
  sms_phone_number: "+14155551212",
  email_address: "crunch@example.com",
  primary_consented_to_service_at: DateTime.current,
  sms_notification_opt_in: :yes,
  email_notification_opt_in: :yes,
  visitor_id: "test_visitor_id",
  bank_name: "Self-help United",
  bank_routing_number: "12345678",
  bank_account_number: "87654321",
  bank_account_type: "checking"
)

Document.find_or_create_by(display_name: "My Employment", document_type: "Employment", client: client, created_at: 1.day.ago, intake: intake)
Document.find_or_create_by(display_name: "Identity Document", document_type: "ID", client: client, created_at: 2.months.ago, intake: intake)

TaxReturn.find_or_create_by(year: 2019, client: client, assigned_user: user).transition_to("intake_ready")
TaxReturn.find_or_create_by(year: 2018, client: client).transition_to("intake_ready")

OutgoingTextMessage.create!(client: client, body: "Hey client, nice to meet you", user: user, sent_at: 3.days.ago, to_phone_number: "+14155551212")
OutgoingTextMessage.create!(client: client, body: "Hope you're having a good day", user: user, sent_at: 2.days.ago, to_phone_number: "+14155551212")
OutgoingTextMessage.create!(client: client, body: "Thanks and have a good night!", user: user, sent_at: 1.day.ago, to_phone_number: "+14155551212")

IncomingTextMessage.create!(client: client, body: "I am sending you some info.", received_at: 1.day.ago, from_phone_number: intake.sms_phone_number)
Note.create!(client: client, user: additional_user, body: "This is an incoming note!")
Note.create!(client: client, user: user, body: "This is an outgoing note :)", created_at: 2.days.ago)

IncomingTextMessage.create!(client: client, body: "What's up with my taxes?", received_at: DateTime.now, from_phone_number: "+14155551212")

other_client = Client.create!(vita_partner: first_org)
Intake::GyrIntake.create(client: other_client, preferred_name: "Tony", email_address: "tiger@example.com", email_notification_opt_in: :yes, visitor_id: "another_test_visitor_id")

married_client = Client.create!(vita_partner: first_org)

# Use this client for portal login; log in by email address & run rails jobs:work for the verification code; see SSN last 4 below
married_intake = Intake::GyrIntake.create!(
  client: married_client,
  preferred_name: "Lucky",
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
  visitor_id: "married_visitor_id",
  primary_consented_to_service_at: DateTime.current,
  primary_consented_to_service: "yes",
  primary_consented_to_service_ip: "127.0.0.1",
)
TaxReturn.create!(client: married_intake.client, year: 2020, status: TaxReturnStatus::STATUSES[:prep_preparing])
FactoryBot.create :verification_attempt
