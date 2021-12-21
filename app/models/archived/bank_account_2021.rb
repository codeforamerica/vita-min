# == Schema Information
#
# Table name: archived_bank_accounts_2021
#
#  id                          :bigint           not null, primary key
#  account_type                :integer
#  encrypted_account_number    :string
#  encrypted_account_number_iv :string
#  encrypted_bank_name         :string
#  encrypted_bank_name_iv      :string
#  encrypted_routing_number    :string
#  encrypted_routing_number_iv :string
#  hashed_account_number       :string
#  hashed_routing_number       :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  archived_intakes_2021_id    :bigint
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

    belongs_to :intake, inverse_of: :bank_account

    attr_encrypted :bank_name, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
    attr_encrypted :routing_number, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
    attr_encrypted :account_number, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
    # Enum values are acceptable BankAccountType values to be sent to the IRS (See efileTypes.xsd)
    enum account_type: { checking: 1, savings: 2 }
    before_save :hash_data

    # map string enum value back to the corresponding integer
    def account_type_code
      self.class.account_types[account_type]
    end

    def duplicates
      DeduplificationService.duplicates(self, :hashed_routing_number, :hashed_account_number)
    end

    def hash_data
      [:routing_number, :account_number].each do |attr|
        if send("#{attr}_changed?") && send(attr).present?
          assign_attributes("hashed_#{attr}" => DeduplificationService.sensitive_attribute_hashed(self, attr))
        end
      end
    end
  end
end
