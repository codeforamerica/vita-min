# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password,
  :name,
  :email,
  :phone_number,
  :additional_info,
  :filename, 
  :bank_account_name,
  :bank_routing_number,
  :bank_account_number
]
