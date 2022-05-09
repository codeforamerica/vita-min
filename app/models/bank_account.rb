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
#  hashed_account_number       :string
#  routing_number              :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  intake_id                   :bigint
#
# Indexes
#
#  index_bank_accounts_on_hashed_account_number  (hashed_account_number)
#  index_bank_accounts_on_intake_id              (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
class BankAccount < ApplicationRecord
  belongs_to :intake
  has_one :client, through: :intake
  attr_encrypted :bank_name, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :account_number, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  # Enum values are acceptable BankAccountType values to be sent to the IRS (See efileTypes.xsd)
  enum account_type: { checking: 1, savings: 2 }
  before_save :hash_account_number

  # map string enum value back to the corresponding integer
  def account_type_code
    self.class.account_types[account_type]
  end

  def duplicates
    DeduplificationService.duplicates(self, :routing_number, :hashed_account_number, from_scope: self.class)
  end

  def hash_account_number
    if account_number_changed? && account_number.present?
      self.hashed_account_number = DeduplificationService.sensitive_attribute_hashed(self, :account_number)
    end
  end
end
