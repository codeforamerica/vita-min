# == Schema Information
#
# Table name: fraud_indicators_timezones
#
#  id           :bigint           not null, primary key
#  activated_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
module Fraud
  module Indicators
    class Timezone < ApplicationRecord
      self.table_name = "fraud_indicators_timezones"
      validates_uniqueness_of :name
      default_scope { where.not(activated_at: nil) }

      def self.safelist
        all.pluck(:name).push(nil)
      end
    end
  end
end

