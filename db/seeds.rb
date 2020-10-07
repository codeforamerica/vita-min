fake_vita_partner = VitaPartner.find_or_create_by(name: 'Fake Vita Partner', zendesk_group_id: 'foo', zendesk_instance_domain: 'eitc')

# basic beta tester
User.where(email: 'skywalker@example.com').first_or_initialize.update(
  name: 'Luke',
  password: 'theforcevita',
  vita_partner: fake_vita_partner,
  is_beta_tester: true
)

client = Client.find_or_create_by(preferred_name: 'Captain', email_address: 'crunch@example.com', vita_partner: fake_vita_partner)

intake = Intake.create

Document.find_or_create_by(display_name: 'My Employment', document_type: 'Employment', client: client, created_at: 1.day.ago, intake: intake)
Document.find_or_create_by(display_name: 'Identity Document', document_type: 'ID', client: client, created_at: 2.months.ago, intake: intake)
