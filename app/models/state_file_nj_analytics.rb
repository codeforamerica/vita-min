# == Schema Information
#
# Table name: state_file_nj_analytics
#
#  id                        :bigint           not null, primary key
#  NJ1040_LINE_12_COUNT      :integer          default(0), not null
#  NJ1040_LINE_15            :integer          default(0), not null
#  NJ1040_LINE_16A           :integer          default(0), not null
#  NJ1040_LINE_16B           :integer          default(0), not null
#  NJ1040_LINE_29            :integer          default(0), not null
#  NJ1040_LINE_31            :integer          default(0), not null
#  NJ1040_LINE_41            :integer          default(0), not null
#  NJ1040_LINE_42            :integer          default(0), not null
#  NJ1040_LINE_43            :integer          default(0), not null
#  NJ1040_LINE_51            :integer          default(0), not null
#  NJ1040_LINE_56            :integer          default(0), not null
#  NJ1040_LINE_58            :integer          default(0), not null
#  NJ1040_LINE_58_IRS        :boolean
#  NJ1040_LINE_59            :integer          default(0), not null
#  NJ1040_LINE_61            :integer          default(0), not null
#  NJ1040_LINE_64            :integer          default(0), not null
#  NJ1040_LINE_65            :integer          default(0), not null
#  NJ1040_LINE_65_DEPENDENTS :integer          default(0), not null
#  NJ1040_LINE_7_SELF        :boolean
#  NJ1040_LINE_7_SPOUSE      :boolean
#  NJ1040_LINE_8_SELF        :boolean
#  NJ1040_LINE_8_SPOUSE      :boolean
#  claimed_as_dep            :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  state_file_nj_intake_id   :bigint           not null
#
# Indexes
#
#  index_state_file_nj_analytics_on_state_file_nj_intake_id  (state_file_nj_intake_id)
#
class StateFileNjAnalytics < ApplicationRecord
  belongs_to :state_file_nj_intake

  def calculated_fields
    nj1040_fields = state_file_nj_intake.tax_calculator.calculate
    required_fields = [
      :NJ1040_LINE_7_SELF, 
      :NJ1040_LINE_7_SPOUSE, 
      :NJ1040_LINE_8_SELF, 
      :NJ1040_LINE_8_SPOUSE, 
      :NJ1040_LINE_12_COUNT, 
      :NJ1040_LINE_15, 
      :NJ1040_LINE_16A, 
      :NJ1040_LINE_16B, 
      :NJ1040_LINE_29,
      :NJ1040_LINE_31,
      :NJ1040_LINE_41,
      :NJ1040_LINE_42,
      :NJ1040_LINE_43,
      :NJ1040_LINE_51, 
      :NJ1040_LINE_56,
      :NJ1040_LINE_58,
      :NJ1040_LINE_58_IRS,
      :NJ1040_LINE_59,
      :NJ1040_LINE_61,
      :NJ1040_LINE_64,
      :NJ1040_LINE_65,
      :NJ1040_LINE_65_DEPENDENTS
    ]
    metabase_metrics = {
      claimed_as_dep: state_file_nj_intake.direct_file_data.claimed_as_dependent?,
    }
    required_fields.each do |metric|
      metabase_metrics[metric] = nj1040_fields[metric] || 0
    end
    metabase_metrics  
  end
end
