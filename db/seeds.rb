fake_vita_partner = VitaPartner.find_or_create_by(name: 'Fake Vita Partner', zendesk_group_id: 'foo', zendesk_instance_domain: 'eitc')

# basic beta tester
user = User.where(email: 'skywalker@example.com').first_or_initialize
user.update(
  name: 'Luke',
  password: 'theforcevita',
  vita_partner: fake_vita_partner,
  is_beta_tester: true
)

client = Client.find_or_create_by(preferred_name: 'Captain', email_address: 'crunch@example.com', vita_partner: fake_vita_partner)

intake = Intake.create

Document.find_or_create_by(display_name: 'My Employment', document_type: 'Employment', client: client, created_at: 1.day.ago, intake: intake)
Document.find_or_create_by(display_name: 'Identity Document', document_type: 'ID', client: client, created_at: 2.months.ago, intake: intake)

OutgoingTextMessage.create!(client: client, body: "Hey client, nice to meet you", user: user, sent_at: 3.days.ago, to_phone_number: "+14155551212")
OutgoingTextMessage.create!(client: client, body: "Hope you're having a good day", user: user, sent_at: 2.days.ago, to_phone_number: "+14155551212")
OutgoingTextMessage.create!(client: client, body: "Thanks and have a good night!", user: user, sent_at: DateTime.now, to_phone_number: "+14155551212")
