# == Schema Information
#
# Table name: archived_bank_accounts_2021
#
#  id                       :bigint           not null, primary key
#  account_number           :text
#  account_type             :integer
#  bank_name                :string
#  hashed_account_number    :string
#  hashed_routing_number    :string
#  routing_number           :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  archived_intakes_2021_id :bigint
#
# Indexes
#
#  index_archived_bank_accounts_2021_on_archived_intakes_2021_id  (archived_intakes_2021_id)
#  index_archived_bank_accounts_2021_on_hashed_account_number     (hashed_account_number)
#  index_archived_bank_accounts_2021_on_hashed_routing_number     (hashed_routing_number)
#
# Foreign Keys
#
#  fk_rails_...  (archived_intakes_2021_id => archived_intakes_2021.id)
#
module Archived
  class BankAccount2021 < ApplicationRecord
    self.table_name = 'archived_bank_accounts_2021'

    belongs_to :intake, inverse_of: :bank_account, foreign_key: 'archived_intakes_2021_id', class_name: 'Archived::Intake::CtcIntake2021'

    # Enum values are acceptable BankAccountType values to be sent to the IRS (See efileTypes.xsd)
    enum account_type: { checking: 1, savings: 2 }
    before_save :hash_data

    encrypts :account_number

    # map string enum value back to the corresponding integer
    def account_type_code
      self.class.account_types[account_type]
    end

    def duplicates
      DeduplicationService.duplicates(self, :hashed_routing_number, :hashed_account_number, from_scope: self.class)
    end

    def hash_data
      [:routing_number, :account_number].each do |attr|
        if send("#{attr}_changed?") && send(attr).present?
          assign_attributes("hashed_#{attr}" => DeduplicationService.sensitive_attribute_hashed(self, attr))
        end
      end
    end
  end
end
