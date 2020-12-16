koalas = Coalition.find_or_create_by(name: "Koala Koalition")
Coalition.find_or_create_by(name: "Cola Coalition")

first_org = VitaPartner.find_or_create_by!(
  name: "Oregano Org",
  display_name: "Oregano Org",
  coalition: koalas,
  zendesk_group_id: "unused",
  zendesk_instance_domain: "unused",
)

VitaPartner.find_or_create_by!(
  name: "Orangutan Organization",
  display_name: "Orangutan Organization",
  coalition: koalas,
  zendesk_group_id: "unused",
  zendesk_instance_domain: "unused",
)

VitaPartner.find_or_create_by(name: "Liberry Site", parent_organization: first_org)

# basic user
user = User.where(email: "skywalker@example.com").first_or_initialize
user.update(
  name: "Luke",
  password: "theforcevita",
  vita_partner: first_org
)

# additional user
additional_user = User.where(email: "princess@example.com").first_or_initialize
additional_user.update(
  name: "Lea",
  password: "theforcevita",
  vita_partner: first_org
)

admin_user = User.where(email: "admin@example.com").first_or_initialize
admin_user.update(
  name: "The Admin",
  password: "theforcevita",
  vita_partner: first_org,
  is_admin: true
)

client = Client.find_or_create_by(vita_partner: first_org)

intake = Intake.create(client: client, preferred_name: "Captain", sms_phone_number: "+14155551212", email_address: "crunch@example.com", sms_notification_opt_in: :yes, email_notification_opt_in: :yes)

Document.find_or_create_by(display_name: "My Employment", document_type: "Employment", client: client, created_at: 1.day.ago, intake: intake)
Document.find_or_create_by(display_name: "Identity Document", document_type: "ID", client: client, created_at: 2.months.ago, intake: intake)

TaxReturn.find_or_create_by(year: 2019, client: client, assigned_user: user).update(status: "intake_open")
TaxReturn.find_or_create_by(year: 2018, client: client).update(status: "intake_open")

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
