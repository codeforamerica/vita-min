# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  active                    :boolean
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :string
#  email                     :string           not null
#  encrypted_access_token    :string
#  encrypted_access_token_iv :string
#  encrypted_password        :string           default(""), not null
#  failed_attempts           :integer          default(0), not null
#  invitation_accepted_at    :datetime
#  invitation_created_at     :datetime
#  invitation_limit          :integer
#  invitation_sent_at        :datetime
#  invitation_token          :string
#  invitations_count         :integer          default(0)
#  is_beta_tester            :boolean          default(FALSE), not null
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :string
#  locked_at                 :datetime
#  name                      :string
#  provider                  :string
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  role                      :string
#  sign_in_count             :integer          default(0), not null
#  suspended                 :boolean
#  ticket_restriction        :string
#  timezone                  :string           default("Eastern Time (US & Canada)")
#  two_factor_auth_enabled   :boolean
#  uid                       :string
#  verified                  :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  invited_by_id             :bigint
#  vita_partner_id           :bigint
#  zendesk_user_id           :bigint
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_vita_partner_id       (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
class User < ApplicationRecord
  devise :database_authenticatable, :lockable, :validatable, :timeoutable, :trackable, :invitable, :recoverable,
         :omniauthable, omniauth_providers: [:zendesk]
  
  belongs_to :vita_partner, optional: true

  attr_encrypted :access_token, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

  validates_presence_of :name

  def self.from_zendesk_oauth(auth)
    data_source = auth.info

    # Watch out for weird capitalization!
    user = where(email: data_source.email.downcase).first_or_initialize do |new_user|
      # If creating user via Zendesk auth, give them a random password. They will need to reset their password.
      new_user.password = Devise.friendly_token[0, 20]
    end

    # update all other fields with latest values from zendesk
    user.update(
      zendesk_user_id: data_source.id,
      uid: auth.uid,
      provider: auth.provider,
      name: data_source.name,
      role: data_source.role,
      ticket_restriction: data_source.ticket_restriction,
      two_factor_auth_enabled: data_source.two_factor_auth_enabled,
      active: data_source.active,
      suspended: data_source.suspended,
      verified: data_source.verified,
      access_token: auth.credentials.token
    )
    user
  end
end
