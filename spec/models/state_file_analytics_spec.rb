# == Schema Information
#
# Table name: state_file_analytics
#
#  id                                            :bigint           not null, primary key
#  az_credit_for_contributions_to_public_schools :integer
#  az_credit_for_contributions_to_qcos           :integer
#  az_pension_exclusion_government               :integer
#  az_pension_exclusion_uniformed_services       :integer
#  canceled_data_transfer_count                  :integer          default(0)
#  dependent_tax_credit                          :integer
#  empire_state_child_credit                     :integer
#  excise_credit                                 :integer
#  family_income_tax_credit                      :integer
#  fed_eitc_amount                               :integer
#  fed_refund_amt                                :integer
#  filing_status                                 :integer
#  household_fed_agi                             :integer
#  id_retirement_benefits_deduction              :integer
#  initiate_data_transfer_first_visit_at         :datetime
#  initiate_df_data_transfer_clicks              :integer          default(0)
#  md_child_dep_care_credit                      :integer
#  md_child_dep_care_subtraction                 :integer
#  md_ctc                                        :integer
#  md_eic                                        :integer
#  md_income_us_gov_subtraction                  :integer
#  md_local_eic                                  :integer
#  md_local_poverty_credit                       :integer
#  md_military_retirement_subtraction            :integer
#  md_poverty_credit                             :integer
#  md_primary_pension_exclusion                  :integer
#  md_public_safety_subtraction                  :integer
#  md_refundable_child_dep_care_credit           :integer
#  md_refundable_eic                             :integer
#  md_senior_tax_credit                          :integer
#  md_spouse_pension_exclusion                   :integer
#  md_ssa_benefits_subtraction                   :integer
#  md_stpickup_addition                          :integer
#  md_total_pension_exclusion                    :integer
#  md_two_income_subtraction                     :integer
#  name_dob_first_visit_at                       :datetime
#  nc_retirement_benefits_bailey                 :integer
#  nc_retirement_benefits_uniformed_services     :integer
#  nyc_eitc                                      :integer
#  nyc_household_credit                          :integer
#  nyc_school_tax_credit                         :integer
#  nys_eitc                                      :integer
#  nys_household_credit                          :integer
#  record_type                                   :string           not null
#  refund_or_owed_amount                         :integer
#  zip_code                                      :string
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  record_id                                     :bigint           not null
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

      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_3).and_return(20)
      allow_any_instance_of(DirectFileData).to receive(:total_qualifying_dependent_care_expenses_or_limit_amt).and_return(30)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_10a).and_return(40)
      allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_11a).and_return(70)
      allow_any_instance_of(Efile::Md::Md502RCalculator).to receive(:calculate_line_11b).and_return(80)
      allow_any_instance_of(DirectFileData).to receive(:fed_taxable_ssb).and_return(90)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_14).and_return(110)
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_ab).and_return(120)
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_u).and_return(130)
      allow_any_instance_of(Efile::Md::Md502SuCalculator).to receive(:calculate_line_v).and_return(140)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_22).and_return(150)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_23).and_return(160)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_29).and_return(170)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_30).and_return(180)
      allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_42).and_return(190)
      allow_any_instance_of(Efile::Md::Md502crCalculator).to receive(:calculate_md502_cr_part_b_line_4).and_return(210)
      allow_any_instance_of(Efile::Md::Md502crCalculator).to receive(:calculate_md502_cr_part_m_line_1).and_return(220)
      allow_any_instance_of(Efile::Md::Md502crCalculator).to receive(:calculate_part_cc_line_7).and_return(230)
      allow_any_instance_of(Efile::Md::Md502crCalculator).to receive(:calculate_part_cc_line_8).and_return(240)
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
          nys_eitc: 555,
          nyc_eitc: 300,
          empire_state_child_credit: 0,
          nyc_school_tax_credit: 125,
          nys_household_credit: 45,
          nyc_household_credit: 0,
        },
        id: {
          id_retirement_benefits_deduction: 500
        },
        nc: {
          nc_retirement_benefits_bailey: 300,
          nc_retirement_benefits_uniformed_services: 400
        },
        md: {
          md_stpickup_addition: 20,
          md_child_dep_care_subtraction: 30,
          md_total_pension_exclusion: 40,
          md_primary_pension_exclusion: 70,
          md_spouse_pension_exclusion: 80,
          md_ssa_benefits_subtraction: 90,
          md_two_income_subtraction: 110,
          md_income_us_gov_subtraction: 120,
          md_military_retirement_subtraction: 130,
          md_public_safety_subtraction: 140,
          md_eic: 150,
          md_poverty_credit: 160,
          md_local_eic: 170,
          md_local_poverty_credit: 180,
          md_refundable_eic: 190,
          md_child_dep_care_credit: 210,
          md_senior_tax_credit: 220,
          md_refundable_child_dep_care_credit: 230,
          md_ctc: 240,
        },
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
