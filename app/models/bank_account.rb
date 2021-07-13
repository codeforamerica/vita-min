# == Schema Information
#
# Table name: bank_accounts
#
#  id                          :bigint           not null, primary key
#  account_type                :integer
#  encrypted_account_number    :string
#  encrypted_account_number_iv :string
#  encrypted_bank_name         :string
#  encrypted_bank_name_iv      :string
#  encrypted_routing_number    :string
#  encrypted_routing_number_iv :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  intake_id                   :bigint
#
# Indexes
#
#  index_bank_accounts_on_intake_id  (intake_id)
#
class BankAccount < ApplicationRecord
  belongs_to :intake
  attr_encrypted :bank_name, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :routing_number, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :account_number, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  # Enum values are acceptable BankAccountType values to be sent to the IRS (See efileTypes.xsd)
  enum account_type: { checking: 1, savings: 2 }

  # map string enum value back to the corresponding integer
  def account_type_code
    self.class.account_types[account_type]
  end
end
