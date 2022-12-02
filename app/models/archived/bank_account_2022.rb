# == Schema Information
#
# Table name: archived_bank_accounts_2022
#
#  id                       :bigint           not null, primary key
#  account_number           :text
#  account_type             :integer
#  bank_name                :string
#  hashed_account_number    :string
#  routing_number           :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  archived_intakes_2022_id :bigint
#
# Indexes
#
#  index_archived_bank_accounts_2022_on_archived_intakes_2022_id  (archived_intakes_2022_id)
#  index_archived_bank_accounts_2022_on_hashed_account_number     (hashed_account_number)
#  index_archived_bank_accounts_2022_on_routing_number            (routing_number)
#
# Foreign Keys
#
#  fk_rails_...  (archived_intakes_2022_id => archived_intakes_2022.id)
#

class Archived::BankAccount2022 < ApplicationRecord
  self.table_name = 'archived_bank_accounts_2022'

  belongs_to :intake, inverse_of: :bank_account, foreign_key: 'archived_intakes_2022_id', class_name: 'Archived::Intake::CtcIntake2022'

  has_one :client, through: :intake
  # Enum values are acceptable BankAccountType values to be sent to the IRS (See efileTypes.xsd)
  enum account_type: { checking: 1, savings: 2 }
  before_save :hash_account_number

  encrypts :account_number

  # map string enum value back to the corresponding integer
  def account_type_code
    self.class.account_types[account_type]
  end

  def duplicates
    DeduplicationService.duplicates(self, :routing_number, :hashed_account_number, from_scope: self.class)
  end

  def incomplete?
    account_number.nil? || routing_number.nil?
  end

  def hash_account_number
    # if account_number_changed? && account_number.present?
    if account_number.present? # temporarily always rewrite the hashed value while we do this cutover.
      self.hashed_account_number = DeduplicationService.sensitive_attribute_hashed(self, :account_number)
    end
  end
end
