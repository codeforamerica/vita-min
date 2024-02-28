# == Schema Information
#
# Table name: state_file_analytics
#
#  id                        :bigint           not null, primary key
#  dependent_tax_credit      :integer
#  empire_state_child_credit :integer
#  excise_credit             :integer
#  family_income_tax_credit  :integer
#  fed_eitc_amount           :integer
#  filing_status             :integer
#  household_fed_agi         :integer
#  nyc_eitc                  :integer
#  nyc_household_credit      :integer
#  nyc_school_tax_credit     :integer
#  nys_eitc                  :integer
#  nys_household_credit      :integer
#  record_type               :string           not null
#  refund_or_owed_amount     :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  record_id                 :bigint           not null
#
# Indexes
#
#  index_state_file_analytics_on_record  (record_type,record_id)
#
require 'rails_helper'

describe StateFileAnalytics do
  describe "#calculated_attrs" do
    before do
      allow_any_instance_of(StateFileBaseIntake).to receive(:calculated_refund_or_owed_amount).and_return(100)
      allow_any_instance_of(DirectFileData).to receive(:fed_eic).and_return(2000)
      allow_any_instance_of(DirectFileData).to receive(:filing_status).and_return(2)
    end

    let(:expected_attributes) {
      {
        fed_eitc_amount: 2000,
        filing_status: 2,
        refund_or_owed_amount: 100
      }
    }

    context "AZ intake" do
      let(:intake) { create :state_file_az_intake }

      it "returns the calculated attributes" do
        expect(StateFileAnalytics.create(record: intake).attributes.symbolize_keys).to include(expected_attributes)
      end
    end

    context "NY intake" do
      let(:intake) { create :state_file_ny_intake }

      it "returns the calculated attributes" do
        expect(StateFileAnalytics.create(record: intake).attributes.symbolize_keys).to include(expected_attributes)
      end
    end
  end
end
