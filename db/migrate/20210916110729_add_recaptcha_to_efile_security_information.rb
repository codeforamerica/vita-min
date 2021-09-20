class AddRecaptchaToEfileSecurityInformation < ActiveRecord::Migration[6.0]
  def change
    add_column :efile_security_informations, :recaptcha_score, :decimal
  end
end
