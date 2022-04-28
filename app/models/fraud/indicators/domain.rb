# == Schema Information
#
# Table name: fraud_indicators_domains
#
#  id           :bigint           not null, primary key
#  activated_at :datetime
#  name         :string
#  risky        :boolean
#  safe         :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_fraud_indicators_domains_on_risky  (risky)
#  index_fraud_indicators_domains_on_safe   (safe)
#
module Fraud
  module Indicators
    class Domain < ApplicationRecord
      self.table_name = "fraud_indicators_domains"

      default_scope { where.not(activated_at: nil) }

      before_validation do
        self.name = name.downcase
      end

      validates :name, format: { with: /(\.)/, message: "Must include top level domain" }, uniqueness: true
      validate :risky_or_safe

      def self.riskylist
        where(risky: true).pluck(:name)
      end

      def self.safelist
        where(safe: true).pluck(:name)
      end

      def active
        activated_at?
      end

      private

      def risky_or_safe
        if risky.present? && safe.present?
          cant_be_both = "Only one of risky or safe are allowed"
          errors.add(:risky, cant_be_both)
          errors.add(:safe, cant_be_both)
        end
        unless risky.present? || safe.present?
          must_be_one = "One of risky or safe are required"
          errors.add(:risky, must_be_one)
          errors.add(:safe, must_be_one)
        end
      end
    end
  end
end
