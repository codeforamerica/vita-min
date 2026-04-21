# == Schema Information
#
# Table name: campaign_contacts
#
#  id                        :bigint           not null, primary key
#  diy_intake_ids            :integer          default([]), is an Array
#  email_address             :citext
#  email_notification_opt_in :boolean          default(FALSE)
#  first_name                :string
#  gyr_intake_ids            :bigint           default([]), is an Array
#  last_name                 :string
#  latest_diy_intake_at      :datetime
#  latest_gyr_intake_at      :datetime
#  latest_signup_at          :datetime
#  locale                    :string
#  sign_up_ids               :bigint           default([]), is an Array
#  sms_notification_opt_in   :boolean          default(FALSE)
#  sms_phone_number          :string
#  state_file_intake_refs    :jsonb            not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_campaign_contacts_on_email_address              (email_address) UNIQUE WHERE (email_address IS NOT NULL)
#  index_campaign_contacts_on_email_notification_opt_in  (email_notification_opt_in)
#  index_campaign_contacts_on_first_name_and_last_name   (first_name,last_name)
#  index_campaign_contacts_on_gyr_intake_ids             (gyr_intake_ids) USING gin
#  index_campaign_contacts_on_gyr_suppression            (suppressed_for_gyr_product_year)
#  index_campaign_contacts_on_latest_gyr_intake_at       (latest_gyr_intake_at)
#  index_campaign_contacts_on_latest_signup_at           (latest_signup_at)
#  index_campaign_contacts_on_sign_up_ids                (sign_up_ids) USING gin
#  index_campaign_contacts_on_sms_notification_opt_in    (sms_notification_opt_in)
#  index_campaign_contacts_on_sms_phone_number           (sms_phone_number)
#  index_campaign_contacts_on_state_file_intake_refs     (state_file_intake_refs) USING gin
#
class CampaignContact < ApplicationRecord
  self.ignored_columns = [:suppressed_for_gyr_product_year]
  validates :sms_phone_number, e164_phone: true, allow_blank: true
  validates :email_address, 'valid_email_2/email': true, allow_blank: true
  has_many :emails, class_name: "CampaignEmail"
  has_many :text_messages, class_name: "CampaignSms"
  has_many :signups, -> { where("signups.id = ANY(campaign_contacts.sign_up_ids)") },
           class_name: "Signup"

  scope :excluding_paused_email_domains, lambda {
    paused_domains = PausedEmailDomain.active.select(:domain)

    where.not(
      "lower(split_part(#{table_name}.email_address, '@', 2)) IN (#{paused_domains.to_sql})"
    )
  }

  def self.with_signups_from_recent_off_season
    joins(:signups).where("signups.created_at >= ?", 1.year.ago).distinct
  end

  # Email -------------
  def self.for_email_scope(scope, message_name)
    case scope
    when :all_eligible   then eligible_for_email(message_name)
    when :recent_signups then eligible_for_email_with_recent_signup(message_name)
    when :prior_fyst     then eligible_for_fyst_email(message_name)
    when :prior_gyr      then eligible_for_gyr_email(message_name)
    else raise ArgumentError, "no valid 'scope' given, use one of the following [:all_eligible, :recent_signups, :prior_fyst or :prior_gyr]"
    end
  end

  def self.eligible_for_email(message_name)
    where(email_notification_opt_in: true).where.not(email_address: [nil, ""]) # opted-in
      .excluding_paused_email_domains
      .where(<<~SQL, message_name: message_name) # contact hasn't been sent this message before
        NOT EXISTS (
          SELECT 1 FROM campaign_emails
          WHERE campaign_emails.campaign_contact_id = campaign_contacts.id
          AND campaign_emails.message_name = :message_name
        )
      SQL
      .where("latest_gyr_intake_at IS NULL OR latest_gyr_intake_at <= ?", gyr_intake_cutoff) # hasn't started an intake this year yet
      .where("latest_diy_intake_at IS NULL OR latest_diy_intake_at <= ?", gyr_intake_cutoff)
  end

  def self.eligible_for_email_with_recent_signup(message_name)
    eligible_for_email(message_name).where("latest_signup_at >= ?", signup_cutoff)
  end

  def self.eligible_for_fyst_email(message_name)
    eligible_for_email(message_name).where("jsonb_array_length(state_file_intake_refs) > 0")
  end

  def self.eligible_for_gyr_email(message_name)
    eligible_for_email(message_name).where("array_length(gyr_intake_ids, 1) > 0")
  end

  # SMS -------------
  def self.for_sms_scope(scope, message_name)
    case scope
    when :all_eligible   then eligible_for_text_message(message_name)
    when :recent_signups then eligible_for_text_message_with_recent_signup(message_name)
    when :prior_fyst     then eligible_for_fyst_sms(message_name)
    when :prior_gyr      then eligible_for_gyr_sms(message_name)
    else raise ArgumentError, "no valid 'scope' given, use one of the following [:all_eligible, :recent_signups, :prior_fyst or :prior_gyr]"
    end
  end

  def self.sms_batch_time_estimate(scope, message_name, batch_size: 1000, msg_delay: 1.second)
    count = for_sms_scope(scope, message_name).count
    return 0 if count.zero?

    batches = (count.to_f / batch_size).ceil
    inter_batch_wait = (batches - 1) * 15.minutes
    send_time = count * msg_delay
    time_estimate = 15.minutes + inter_batch_wait + send_time

    total_seconds = time_estimate.to_i
    days = total_seconds / 86400
    hours = (total_seconds % 86400) / 3600
    minutes = (total_seconds % 3600) / 60
    seconds = total_seconds % 60

    parts = []
    parts << "#{days} days" if days > 0
    parts << "#{hours} hours" if hours > 0
    parts << "#{minutes} minutes" if minutes > 0
    parts << "#{seconds} seconds" if seconds > 0

    human_time = parts.join(" and ")

    puts "**********~~~~Sending #{count} '#{message_name}' text-messages scoped for #{scope} will take an estimated #{human_time}~~~~**********"
    time_estimate
  end

  def self.eligible_for_text_message(message_name)
    where(sms_notification_opt_in: true).where.not(sms_phone_number: [nil, ""]) # opted-in
      .where(<<~SQL, message_name: message_name) # phone number hasn't been sent this message before, not searching by contact id since two campaign contacts can have the same phone number
        NOT EXISTS (
          SELECT 1 FROM campaign_sms
          WHERE campaign_sms.to_phone_number = campaign_contacts.sms_phone_number
          AND campaign_sms.message_name = :message_name
        )
      SQL
      .where("latest_gyr_intake_at IS NULL OR latest_gyr_intake_at <= ?", gyr_intake_cutoff) # hasn't started an intake this year yet
      .where("latest_diy_intake_at IS NULL OR latest_diy_intake_at <= ?", gyr_intake_cutoff)
  end

  def self.eligible_for_text_message_with_recent_signup(message_name)
    # contacts with signups that were created from the end of the last filing season onward
    eligible_for_text_message(message_name).where("latest_signup_at >= ?", signup_cutoff)
  end

  def self.eligible_for_fyst_sms(message_name)
    eligible_for_text_message(message_name).where("jsonb_array_length(state_file_intake_refs) > 0")
  end

  def self.eligible_for_gyr_sms(message_name)
    eligible_for_text_message(message_name).where("array_length(gyr_intake_ids, 1) > 0")
  end

  def self.signup_cutoff
    year = MultiTenantService.new(:gyr).current_tax_year - 1
    Rails.configuration.tax_year_filing_seasons[year].last
  end

  def self.gyr_intake_cutoff
    Rails.configuration.start_of_unique_links_only_intake
  end
end
