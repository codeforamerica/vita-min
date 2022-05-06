module Fraud
  module Indicators
    class RoutingNumber < ApplicationRecord
      self.table_name = "fraud_indicators_routing_numbers"

      default_scope { where.not(activated_at: nil) }

      validates :routing_number, length: { is: 9 }, uniqueness: true
      validates :bank_name, presence: true

      def self.riskylist
        all.map { |instance| DeduplificationService.sensitive_attribute_hashed(instance, :routing_number) }
      end

      def active
        activated_at?
      end
    end
  end
end
