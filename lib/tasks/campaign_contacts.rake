namespace :campaign_contacts do
  desc "Backfill campaign_contacts from state file intakes, GYR intakes, and signups"
  task backfill: :environment do
    # TODO: when running this task after the first time, we should have a "created after: time of first run" param and only do signups
    # or should it be on create of signup, ask if we expect to have more signups through out the season??
    puts "🌸 🌸 🌸 Current CampaignContact count is: #{CampaignContact.count} 🌸 🌸 🌸"

    backfill_from_state_file_intakes
    backfill_from_gyr_intakes
    backfill_from_signups

    puts "🌺 🌺 🌺 Done creating/updating CampaignContacts with information from GYR Intakes, StateFile Intakes or Sign-ups. Current CampaignContact count is: #{CampaignContact.count} 🌺 🌺 🌺"
  end
end

def backfill_from_gyr_intakes
  Intake::GyrIntake.contactable
                   .where("created_at > ?", Date.new(2021, 2, 1))
                   .find_each do |intake|
    upsert_campaign_contact!(
      source: :gyr,
      source_id: intake.id,
      first_name: intake.primary_first_name,
      last_name: intake.primary_last_name,
      email: intake.email_address,
      phone: intake.sms_phone_number,
      email_opt_in: intake.email_notification_opt_in == "yes",
      sms_opt_in: intake.sms_notification_opt_in == "yes",
      locale: intake.locale
    )
  end
end

def backfill_from_state_file_intakes
  StateFile::StateInformationService.state_intake_classes.each do |klass|
    klass.contactable.find_each do |intake|
      upsert_campaign_contact!(
        source: :state_file,
        source_id: intake.id,
        first_name: intake.primary_first_name,
        last_name: intake.primary_last_name,
        email: intake.email_address,
        phone: intake.phone_number,
        email_opt_in: intake.email_notification_opt_in == "yes",
        sms_opt_in: intake.sms_notification_opt_in == "yes",
        locale: intake.locale,
        state_file_ref: {
          id: intake.id,
          type: klass.name,
          state: intake.state_code,
          tax_year: intake.tax_return_year
        }
      )
    end
  end
end

def backfill_from_signups
  Signup.find_each do |signup|
    upsert_campaign_contact!(
      source: :signup,
      source_id: signup.id,
      first_name: signup.name,
      email: signup.email_address,
      phone: signup.phone_number,
      email_opt_in: signup.email_address.present?,
      sms_opt_in: signup.phone_number.present?
    )
  end
end

def upsert_campaign_contact!(source:, source_id:, first_name:, last_name: nil, email:, phone:, email_opt_in:, sms_opt_in:, locale: nil, state_file_ref: nil)
  contact = nil

  if email.present?
    contact = CampaignContact.where(email_address: email).first
  end

  if contact.nil? && phone.present? && (!email_opt_in && email.blank?)
    contact = CampaignContact.find_by(sms_phone_number: phone)
  end

  contact ||= CampaignContact.new

  contact.email_address ||= email
  contact.sms_phone_number ||= phone
  contact.first_name = choose_name(contact.first_name, first_name, source: source)
  contact.last_name = choose_name(contact.last_name, last_name, source: source)
  contact.email_notification_opt_in = contact.email_notification_opt_in || email_opt_in
  contact.sms_notification_opt_in = contact.sms_notification_opt_in || sms_opt_in
  contact.locale ||= locale

  case source
  when :gyr
    contact.gyr_intake_ids = (contact.gyr_intake_ids + [source_id]).uniq
  when :signup
    contact.sign_up_ids = (contact.sign_up_ids + [source_id]).uniq
  end

  if state_file_ref.present?
    refs = contact.state_file_intake_refs || []
    refs << state_file_ref unless refs.any? { |r| r["id"] == state_file_ref[:id] && r["type"] == state_file_ref[:type] }
    contact.state_file_intake_refs = refs
  end

  contact.save!
end

def choose_name(existing, incoming, source:)
  return existing if incoming.blank?
  return incoming if existing.blank?

  # prefer intake names over signup names
  source == :signup ? existing : incoming
end

