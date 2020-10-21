fake_vita_partner = VitaPartner.find_or_create_by(name: "Fake Vita Partner", zendesk_group_id: "foo", zendesk_instance_domain: "eitc")

# basic beta tester
beta_user = User.where(email: "skywalker@example.com").first_or_initialize
beta_user.update(
  name: "Luke",
  password: "theforcevita",
  vita_partner: fake_vita_partner,
  is_beta_tester: true
)

# additional tester
additional_user = User.where(email: "princess@example.com").first_or_initialize
additional_user.update(
  name: "Lea",
  password: "theforcevita",
  vita_partner: fake_vita_partner
)

client = Client.find_or_create_by(preferred_name: "Captain", email_address: "crunch@example.com", vita_partner: fake_vita_partner)

intake = Intake.create(client: client)

Document.find_or_create_by(display_name: "My Employment", document_type: "Employment", client: client, created_at: 1.day.ago, intake: intake)
Document.find_or_create_by(display_name: "Identity Document", document_type: "ID", client: client, created_at: 2.months.ago, intake: intake)

TaxReturn.find_or_create_by(year: 2019, client: client, assigned_user: beta_user)
TaxReturn.find_or_create_by(year: 2018, client: client)

OutgoingTextMessage.create!(client: client, body: "Hey client, nice to meet you", user: beta_user, sent_at: 3.days.ago, to_phone_number: "+14155551212")
OutgoingTextMessage.create!(client: client, body: "Hope you're having a good day", user: beta_user, sent_at: 2.days.ago, to_phone_number: "+14155551212")
OutgoingTextMessage.create!(client: client, body: "Thanks and have a good night!", user: beta_user, sent_at: 1.day.ago, to_phone_number: "+14155551212")

IncomingTextMessage.create!(client: client, body: "I am sending you some info.", user: beta_user, received_at: 1.day.ago, from_phone_number: client.sms_phone_number)
Note.create!(client: client, user: additional_user, body: "This is an incoming note!")
Note.create!(client: client, user: beta_user, body: "This is an outgoing note :)", created_at: 2.days.ago)

IncomingTextMessage.create!(client: client, body: "What's up with my taxes?", received_at: DateTime.now, from_phone_number: "+14155551212")

other_client = Client.find_or_create_by(preferred_name: "Tony", email_address: "tiger@example.com", vita_partner: fake_vita_partner)
Intake.create(client: other_client)
