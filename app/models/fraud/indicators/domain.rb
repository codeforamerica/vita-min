# == Schema Information
#
# Table name: fraud_indicators_domains
#
#  id           :bigint           not null, primary key
#  activated_at :datetime
#  deny         :boolean
#  name         :string
#  safe         :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_fraud_indicators_domains_on_deny  (deny)
#  index_fraud_indicators_domains_on_safe  (safe)
#
module Fraud
  module Indicators
    class Domain < ApplicationRecord
      self.table_name = "fraud_indicators_domains"

      default_scope { where.not(activated_at: nil) }

      before_validation do
        self.name = name.downcase
      end

      validates :name, format: { with: /(\.)/ }
      validate :deny_or_safe

      def self.denylist
        where(deny: true).pluck(:name)
      end

      def self.safelist
        where(safe: true).pluck(:name)
      end

      private

      def deny_or_safe
        if deny.present? && safe.present?
          cant_be_both = "Only one of deny or safe are allowed"
          errors.add(:deny, cant_be_both)
          errors.add(:safe, cant_be_both)
        end
        unless deny.present? || safe.present?
          must_be_one = "One of deny or safe are required"
          errors.add(:deny, must_be_one)
          errors.add(:safe, must_be_one)
        end
      end
    end
  end
end
