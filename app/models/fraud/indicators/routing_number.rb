# == Schema Information
#
# Table name: fraud_indicators_routing_numbers
#
#  id             :bigint           not null, primary key
#  activated_at   :datetime
#  bank_name      :string
#  extra_points   :integer
#  routing_number :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
module Fraud
  module Indicators
    class RoutingNumber < ApplicationRecord
      self.table_name = "fraud_indicators_routing_numbers"

      default_scope { where.not(activated_at: nil) }

      validates :routing_number, length: { is: 9 }, uniqueness: true
      validates :bank_name, presence: true

      def self.comparison_column
        :routing_number
      end

      def self.riskylist_records
        all
      end

      def name
        routing_number
      end

      def active
        activated_at?
      end
    end
  end
end
