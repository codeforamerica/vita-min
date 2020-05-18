# == Schema Information
#
# Table name: users
#
#  id                      :bigint           not null, primary key
#  active                  :boolean
#  email                   :string
#  name                    :string
#  provider                :string
#  role                    :string
#  suspended               :boolean
#  ticket_restriction      :string
#  two_factor_auth_enabled :boolean
#  uid                     :string
#  verified                :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organization_id         :bigint
#  zendesk_user_id         :bigint
#
class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:zendesk]

  def self.from_zendesk_oauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      # this only runs on initialize

      data_source = auth.info
      puts "\n\nreceived auth data: #{data_source}\n\n"

      user.zendesk_user_id = data_source.id
      user.name = data_source.name
      user.email = data_source.email
      user.role = data_source.role
      user.organization_id = data_source.organization_id
      user.ticket_restriction = data_source.ticket_restriction
      user.two_factor_auth_enabled = data_source.two_factor_auth_enabled
      user.active = data_source.active
      user.suspended = data_source.suspended
      user.verified = data_source.verified
    end
  end

  def intake
    nil
  end
end
