class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:idme]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
    end
  end
end
