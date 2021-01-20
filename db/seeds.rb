koalas = Coalition.find_or_create_by(name: "Koala Koalition")
Coalition.find_or_create_by(name: "Cola Coalition")

first_org = VitaPartner.find_or_create_by!(
  name: "Oregano Org",
  coalition: koalas
)

VitaPartner.find_or_create_by!(
  name: "Orangutan Organization",
  coalition: koalas,
)

first_site = VitaPartner.find_or_create_by!(
  name: "Liberry Site",
  parent_organization: first_org,
)

# basic user
user = User.where(email: "skywalker@example.com").first_or_initialize
user.update(
  name: "Luke",
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
  name: "Lea",
  password: "theforcevita")
additional_user.update(role: OrganizationLeadRole.create(organization: first_org)) if additional_user.role_type != OrganizationLeadRole::TYPE

admin_user = User.where(email: "admin@example.com").first_or_initialize
admin_user.update(
  name: "The Admin",
  password: "theforcevita")
admin_user.update(role: AdminRole.create) if admin_user.role_type != AdminRole::TYPE

client = Client.find_or_create_by(vita_partner: first_org)

intake = Intake.create(client: client, preferred_name: "Captain", sms_phone_number: "+14155551212", email_address: "crunch@example.com", sms_notification_opt_in: :yes, email_notification_opt_in: :yes)

Document.find_or_create_by(display_name: "My Employment", document_type: "Employment", client: client, created_at: 1.day.ago, intake: intake)
Document.find_or_create_by(display_name: "Identity Document", document_type: "ID", client: client, created_at: 2.months.ago, intake: intake)

TaxReturn.find_or_create_by(year: 2019, client: client, assigned_user: user).update(status: "intake_ready")
TaxReturn.find_or_create_by(year: 2018, client: client).update(status: "intake_ready")

OutgoingTextMessage.create!(client: client, body: "Hey client, nice to meet you", user: user, sent_at: 3.days.ago, to_phone_number: "+14155551212")
OutgoingTextMessage.create!(client: client, body: "Hope you're having a good day", user: user, sent_at: 2.days.ago, to_phone_number: "+14155551212")
OutgoingTextMessage.create!(client: client, body: "Thanks and have a good night!", user: user, sent_at: 1.day.ago, to_phone_number: "+14155551212")

IncomingTextMessage.create!(client: client, body: "I am sending you some info.", received_at: 1.day.ago, from_phone_number: intake.sms_phone_number)
Note.create!(client: client, user: additional_user, body: "This is an incoming note!")
Note.create!(client: client, user: user, body: "This is an outgoing note :)", created_at: 2.days.ago)

IncomingTextMessage.create!(client: client, body: "What's up with my taxes?", received_at: DateTime.now, from_phone_number: "+14155551212")

other_client = Client.create!(vita_partner: first_org)
Intake.create(client: other_client, preferred_name: "Tony", email_address: "tiger@example.com", email_notification_opt_in: :yes)

married_client = Client.create!(vita_partner: first_org)

married_intake = Intake.create!(
  client: married_client,
  preferred_name: "Lucky",
  sms_phone_number: "+14155551212",
  email_address: "charms@example.com",
  sms_notification_opt_in: :yes,
  email_notification_opt_in: :yes,
  filing_joint: "yes",
  spouse_first_name: "Marsha",
  spouse_last_name: "Charms",
  spouse_email_address: "justthemarshmallows@example.com",
)
