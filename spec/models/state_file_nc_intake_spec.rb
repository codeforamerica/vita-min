# == Schema Information
#
# Table name: state_file_nc_intakes
#
#  id                                :bigint           not null, primary key
#  account_number                    :string
#  account_type                      :integer          default("unfilled"), not null
#  city                              :string
#  consented_to_terms_and_conditions :integer          default("unfilled"), not null
#  contact_preference                :integer          default("unfilled"), not null
#  county_during_hurricane_helene    :string
#  current_sign_in_at                :datetime
#  current_sign_in_ip                :inet
#  current_step                      :string
#  date_electronic_withdrawal        :date
#  df_data_import_succeeded_at       :datetime
#  df_data_imported_at               :datetime
#  eligibility_ed_loan_cancelled     :integer          default("no"), not null
#  eligibility_ed_loan_emp_payment   :integer          default("no"), not null
#  eligibility_lived_in_state        :integer          default("unfilled"), not null
#  eligibility_out_of_state_income   :integer          default("unfilled"), not null
#  eligibility_withdrew_529          :integer          default("unfilled"), not null
#  email_address                     :citext
#  email_address_verified_at         :datetime
#  email_notification_opt_in         :integer          default("unfilled"), not null
#  failed_attempts                   :integer          default(0), not null
#  federal_return_status             :string
#  hashed_ssn                        :string
#  last_sign_in_at                   :datetime
#  last_sign_in_ip                   :inet
#  locale                            :string           default("en")
#  locked_at                         :datetime
#  message_tracker                   :jsonb
#  moved_after_hurricane_helene      :integer          default(0), not null
#  payment_or_deposit_type           :integer          default("unfilled"), not null
#  phone_number                      :string
#  phone_number_verified_at          :datetime
#  primary_birth_date                :date
#  primary_esigned                   :integer          default("unfilled"), not null
#  primary_esigned_at                :datetime
#  primary_first_name                :string
#  primary_last_name                 :string
#  primary_middle_initial            :string
#  primary_suffix                    :string
#  primary_veteran                   :integer          default("unfilled"), not null
#  raw_direct_file_data              :text
#  raw_direct_file_intake_data       :jsonb
#  referrer                          :string
#  residence_county                  :string
#  routing_number                    :string
#  sales_use_tax                     :decimal(12, 2)
#  sales_use_tax_calculation_method  :integer          default("unfilled"), not null
#  sign_in_count                     :integer          default(0), not null
#  sms_notification_opt_in           :integer          default("unfilled"), not null
#  source                            :string
#  spouse_birth_date                 :date
#  spouse_esigned                    :integer          default("unfilled"), not null
#  spouse_esigned_at                 :datetime
#  spouse_first_name                 :string
#  spouse_last_name                  :string
#  spouse_middle_initial             :string
#  spouse_suffix                     :string
#  spouse_veteran                    :integer          default("unfilled"), not null
#  ssn                               :string
#  street_address                    :string
#  tribal_member                     :integer          default("unfilled"), not null
#  tribal_wages_amount               :decimal(12, 2)
#  unsubscribed_from_email           :boolean          default(FALSE), not null
#  untaxed_out_of_state_purchases    :integer          default("unfilled"), not null
#  withdraw_amount                   :integer
#  zip_code                          :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  federal_submission_id             :string
#  primary_state_id_id               :bigint
#  spouse_state_id_id                :bigint
#  visitor_id                        :string
#
# Indexes
#
#  index_state_file_nc_intakes_on_hashed_ssn           (hashed_ssn)
#  index_state_file_nc_intakes_on_primary_state_id_id  (primary_state_id_id)
#  index_state_file_nc_intakes_on_spouse_state_id_id   (spouse_state_id_id)
#
require 'rails_helper'

RSpec.describe StateFileNcIntake, type: :model do
  it_behaves_like :state_file_base_intake, factory: :state_file_nc_intake

  describe "#calculate_sales_use_tax" do
    let(:intake) { create :state_file_nc_intake }
    it "calculates the sales use tax using the nc_taxable_income" do
      allow(intake.calculator.lines).to receive(:[]).with(:NCD400_LINE_14).and_return(double(value: 2500))
      expect(intake.calculate_sales_use_tax).to eq 2
    end
  end

  describe "#disaster_relief_county" do
    let(:intake) { create :state_file_nc_intake, residence_county: residence_county, county_during_hurricane_helene: county_during_hurricane_helene, moved_after_hurricane_helene: moved_after_hurricane_helene }
    let(:residence_county) { nil }
    let(:county_during_hurricane_helene) { nil }
    let(:moved_after_hurricane_helene) { "unfilled" }
    let(:designated_county) { "011" } # Buncombe county
    let(:undesignated_county) { "001" } # Alamance county

    context "when residence county is in a designated hurricane relief county" do
      let(:residence_county) { designated_county }

      it "returns 'county name_Helene'" do
        expect(intake.disaster_relief_county).to eq "Buncombe_Helene"
      end
    end

    context "when residence county is in an undesignated hurricane relief county" do
      let(:residence_county) { undesignated_county }

      context "when moved_after_hurricane_helene" do
        let(:moved_after_hurricane_helene) { "yes" }

        context "when county_during_hurricane_helene is a designated county" do
          let(:county_during_hurricane_helene) { designated_county }

          it "returns 'county residence name_Helene;county during hurricane_Helene'" do
            expect(intake.disaster_relief_county).to eq "Alamance_Helene;Buncombe_Helene"
          end
        end

        context "when county_during_hurricane_helene is an undesignated county" do
          let(:county_during_hurricane_helene) { undesignated_county }

          it "returns 'county name_Helene'" do
            expect(intake.disaster_relief_county).to eq "Alamance_Helene"
          end
        end
      end

      context "when didn't moved_after_hurricane_helene" do
        let(:moved_after_hurricane_helene) { "no" }

        it "returns 'county name_Helene'" do
          expect(intake.disaster_relief_county).to eq "Alamance_Helene"
        end
      end
    end
  end
end
