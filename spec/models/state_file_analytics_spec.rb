# == Schema Information
#
# Table name: state_file_analytics
#
#  id                                    :bigint           not null, primary key
#  canceled_data_transfer_count          :integer          default(0)
#  dependent_tax_credit                  :integer
#  empire_state_child_credit             :integer
#  excise_credit                         :integer
#  family_income_tax_credit              :integer
#  fed_eitc_amount                       :integer
#  fed_refund_amt                        :integer
#  filing_status                         :integer
#  household_fed_agi                     :integer
#  initiate_data_transfer_first_visit_at :datetime
#  initiate_df_data_transfer_clicks      :integer          default(0)
#  name_dob_first_visit_at               :datetime
#  nyc_eitc                              :integer
#  nyc_household_credit                  :integer
#  nyc_school_tax_credit                 :integer
#  nys_eitc                              :integer
#  nys_household_credit                  :integer
#  record_type                           :string           not null
#  refund_or_owed_amount                 :integer
#  zip_code                              :string
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  record_id                             :bigint           not null
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
      allow_any_instance_of(DirectFileData).to receive(:fed_refund_amt).and_return(1300)
      allow_any_instance_of(DirectFileData).to receive(:fed_eic).and_return(2000)
      allow_any_instance_of(DirectFileData).to receive(:fed_agi).and_return(3000)
      allow_any_instance_of(DirectFileData).to receive(:filing_status).and_return(2)
      allow_any_instance_of(DirectFileData).to receive(:mailing_zip).and_return("10128")

      allow_any_instance_of(Efile::Az::Az301Calculator).to receive(:calculate_line_6a).and_return(50)
      allow_any_instance_of(Efile::Az::Az301Calculator).to receive(:calculate_line_7a).and_return(60)
      allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_29a).and_return(100)
      allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_29b).and_return(200)
      allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_50).and_return(80)
      allow_any_instance_of(Efile::Az::Az140Calculator).to receive(:calculate_line_56).and_return(40)

      allow_any_instance_of(Efile::Nc::D400ScheduleSCalculator).to receive(:calculate_line_20).and_return(300)
      allow_any_instance_of(Efile::Nc::D400ScheduleSCalculator).to receive(:calculate_line_21).and_return(400)

      allow_any_instance_of(Efile::Id::Id39RCalculator).to receive(:calculate_sec_b_line_8f).and_return(500)
    end

    let(:global_attributes) do
      {
        household_fed_agi: 3000,
        fed_eitc_amount: 2000,
        filing_status: 2,
        fed_refund_amt: 1300,
        refund_or_owed_amount: 100,
        zip_code: "10128"
      }
    end
    let(:all_attributes) do
      global_attributes.merge(state_attributes)
    end
    let(:state_attributes_map) do
      {
        az: {
          dependent_tax_credit: 0,
          excise_credit: 40,
          family_income_tax_credit: 80,
          az_pension_exclusion_government: 100,
          az_pension_exclusion_uniformed_services: 200,
          az_credit_for_contributions_to_qcos: 50,
          az_credit_for_contributions_to_public_schools: 60,
        },
        ny: {
          nys_eitc: 600,
          nyc_eitc: 300,
          empire_state_child_credit: 0,
          nyc_school_tax_credit: 125,
          nys_household_credit: 0,
          nyc_household_credit: 0,
        },
        id: {
          id_retirement_benefits_deduction: 500
        },
        nc: {
          nc_retirement_benefits_bailey: 300,
          nc_retirement_benefits_uniformed_services: 400
        },
        md: {},
        nj: {}
      }
    end

    StateFile::StateInformationService.active_state_codes.each do |state_code|
      context "#{state_code} calculator implements #analytics_attrs" do
        let(:intake) { create "state_file_#{state_code}_intake".to_sym, :with_spouse }
        let(:state_attributes) { state_attributes_map[state_code.to_sym] }

        it "#calculated_attrs returns attributes for state and global attributes" do
          analytics = StateFileAnalytics.create(record: intake)
          expect(analytics.calculated_attrs.symbolize_keys).to match(all_attributes)
        end
      end
    end
  end
end
