# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password,
  :name,
  :primary_first_name,
  :primary_last_name,
  :spouse_first_name,
  :spouse_last_name,
  :email,
  :email_address,
  :email_address_confirmation,
  :spouse_email_address,
  :phone_number,
  :additional_info,
  :filename,
  :bank_name,
  :bank_routing_number,
  :bank_account_number,
  :primary_last_four_ssn,
  :spouse_last_four_ssn,
  :last_four_or_client_id,
]
