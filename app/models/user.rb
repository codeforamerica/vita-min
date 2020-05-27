# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  active                    :boolean
#  email                     :string
#  encrypted_access_token    :string
#  encrypted_access_token_iv :string
#  name                      :string
#  provider                  :string
#  role                      :string
#  suspended                 :boolean
#  ticket_restriction        :string
#  two_factor_auth_enabled   :boolean
#  uid                       :string
#  verified                  :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  zendesk_user_id           :bigint
#
class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:zendesk]

  attr_encrypted :access_token, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

  def self.from_zendesk_oauth(auth)
    data_source = auth.info

    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.update(
        zendesk_user_id: data_source.id,
        name: data_source.name,
        email: data_source.email,
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
