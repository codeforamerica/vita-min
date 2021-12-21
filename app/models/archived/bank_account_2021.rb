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
