# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  birth_date                :string
#  city                      :string
#  consented_to_service      :integer          default("unfilled"), not null
#  consented_to_service_at   :datetime
#  consented_to_service_ip   :string
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :inet
#  email                     :string
#  email_notification_opt_in :integer          default("unfilled"), not null
#  encrypted_ssn             :string
#  encrypted_ssn_iv          :string
#  first_name                :string
#  is_spouse                 :boolean          default(FALSE)
#  last_name                 :string
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :inet
#  phone_number              :string
#  provider                  :string
#  sign_in_count             :integer          default(0), not null
#  sms_notification_opt_in   :integer          default("unfilled"), not null
#  state                     :string
#  street_address            :string
#  uid                       :string
#  zip_code                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  intake_id                 :bigint           not null
#
# Indexes
#
#  index_users_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#

class User < ApplicationRecord
  devise :omniauthable, :trackable, omniauth_providers: [:idme]
  belongs_to :intake

  attr_encrypted :ssn, key: Rails.application.credentials.db_encryption_key

  enum sms_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :sms_notification_opt_in
  enum email_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :email_notification_opt_in
  enum consented_to_service: { unfilled: 0, yes: 1, no: 2 }, _prefix: :consented_to_service

  def self.temporary_fake_idme_data(auth_info)
    OpenStruct.new(
      first_name: "Fake",
      last_name: "Person",
      email: auth_info.email,
      birth_date: "1991-01-20",
      phone: auth_info.phone,
      social: auth_info.social,
      street: "927 Mission St",
      city: "San Francisco",
      state: "California",
      zip_code: auth_info.zip_code,
    )
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      # this only runs on initialize

      data_source = auth.info
      # the ID.me sandbox does not give us full data to work with
      unless Rails.env.production? || auth.info.birth_date.present?
        data_source = temporary_fake_idme_data(auth.info)
      end

      user.first_name = data_source.first_name
      user.last_name = data_source.last_name
      user.email = data_source.email
      user.birth_date = data_source.birth_date
      user.phone_number = data_source.phone
      user.ssn = data_source.social
      user.street_address = data_source.street
      user.city = data_source.city
      user.state = States.key_for_name(data_source.state)
      user.zip_code = data_source.zip_code
    end
  end

  def contact_info_filtered_by_preferences
    contact_info = {}
    contact_info[:phone_number] = phone_number if sms_notification_opt_in_yes?
    contact_info[:email] = email if email_notification_opt_in_yes?
    contact_info
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def parsed_birth_date
    Date.strptime(birth_date, "%Y-%m-%d")
  end

  def formatted_phone_number
    Phonelib.parse(phone_number).local_number
  end

  def ssn_last_four
    ssn.last(4)
  end
end
