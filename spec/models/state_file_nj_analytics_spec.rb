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
require 'rails_helper'

describe StateFileNjAnalytics do
  describe "#calculated_attrs" do
    let(:intake) { create :state_file_nj_intake }
  
    it "sets intake columns for metabase analytics" do
      analytics_record = StateFileNjAnalytics.create(state_file_nj_intake: intake)

      expected_claimed_as_dep = true
      expected_line_7_self = true
      expected_line_7_spouse = true
      expected_line_8_self = true
      expected_line_8_spouse = true
      expected_line_12_count = 18
      expected_line_15 = 10_000
      expected_line_16a = 20_000
      expected_line_16b = 30_000
      expected_line_29 = 40_000
      expected_line_31 = 1_000
      expected_line_41 = 2_000
      expected_line_42 = 3_000
      expected_line_43 = 4_000
      expected_line_51 = 5_000
      expected_line_56 = 6_000
      expected_line_58 = 7_000
      expected_line_58_irs = true
      expected_line_59 = 9_000
      expected_line_61 = 9
      expected_line_64 = 10
      expected_line_65 = 1_000
      expected_line_65_dependents = 3
  
      allow(analytics_record.state_file_nj_intake.direct_file_data).to receive(:claimed_as_dependent?).and_return expected_claimed_as_dep
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:line_7_self_checkbox).and_return expected_line_7_self
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:line_7_spouse_checkbox).and_return expected_line_7_spouse
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:line_8_self_checkbox).and_return expected_line_8_self
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:line_8_spouse_checkbox).and_return expected_line_8_spouse
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:line_12_count).and_return expected_line_12_count
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_15).and_return expected_line_15
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_16a).and_return expected_line_16a
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_16b).and_return expected_line_16b
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_29).and_return expected_line_29
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_31).and_return expected_line_31
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_41).and_return expected_line_41
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_42).and_return expected_line_42
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_43).and_return expected_line_43
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_51).and_return expected_line_51
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_56).and_return expected_line_56
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_58).and_return expected_line_58
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_58_irs).and_return expected_line_58_irs
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_59).and_return expected_line_59
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_61).and_return expected_line_61
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_64).and_return expected_line_64
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_65).and_return expected_line_65
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:number_of_dependents_age_5_younger).and_return expected_line_65_dependents

      columns = analytics_record.calculated_fields

      expect(columns[:claimed_as_dep]).to eq(expected_claimed_as_dep)
      expect(columns[:NJ1040_LINE_7_SELF]).to eq(expected_line_7_self)
      expect(columns[:NJ1040_LINE_7_SPOUSE]).to eq(expected_line_7_spouse)
      expect(columns[:NJ1040_LINE_8_SELF]).to eq(expected_line_8_self)
      expect(columns[:NJ1040_LINE_8_SPOUSE]).to eq(expected_line_8_spouse)
      expect(columns[:NJ1040_LINE_12_COUNT]).to eq(expected_line_12_count)
      expect(columns[:NJ1040_LINE_15]).to eq(expected_line_15)
      expect(columns[:NJ1040_LINE_16A]).to eq(expected_line_16a)
      expect(columns[:NJ1040_LINE_16B]).to eq(expected_line_16b)
      expect(columns[:NJ1040_LINE_29]).to eq(expected_line_29)
      expect(columns[:NJ1040_LINE_31]).to eq(expected_line_31)
      expect(columns[:NJ1040_LINE_41]).to eq(expected_line_41)
      expect(columns[:NJ1040_LINE_42]).to eq(expected_line_42)
      expect(columns[:NJ1040_LINE_43]).to eq(expected_line_43)
      expect(columns[:NJ1040_LINE_51]).to eq(expected_line_51)
      expect(columns[:NJ1040_LINE_56]).to eq(expected_line_56)
      expect(columns[:NJ1040_LINE_58]).to eq(expected_line_58)
      expect(columns[:NJ1040_LINE_58_IRS]).to eq(expected_line_58_irs)
      expect(columns[:NJ1040_LINE_59]).to eq(expected_line_59)
      expect(columns[:NJ1040_LINE_61]).to eq(expected_line_61)
      expect(columns[:NJ1040_LINE_64]).to eq(expected_line_64)
      expect(columns[:NJ1040_LINE_65]).to eq(expected_line_65)
      expect(columns[:NJ1040_LINE_65_DEPENDENTS]).to eq(expected_line_65_dependents)
    end
  end
end
