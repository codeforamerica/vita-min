# == Schema Information
#
# Table name: state_file_nc_intakes
#
#  id                                :bigint           not null, primary key
#  account_number                    :string
#  account_type                      :integer          default("unfilled"), not null
#  city                              :string
#  consented_to_sms_terms            :integer          default("unfilled"), not null
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
#  extension_payments_amount         :decimal(12, 2)
#  failed_attempts                   :integer          default(0), not null
#  federal_return_status             :string
#  hashed_ssn                        :string
#  last_sign_in_at                   :datetime
#  last_sign_in_ip                   :inet
#  locale                            :string           default("en")
#  locked_at                         :datetime
#  message_tracker                   :jsonb
#  moved_after_hurricane_helene      :integer          default("unfilled"), not null
#  out_of_country                    :integer          default("unfilled"), not null
#  paid_extension_payments           :integer          default("unfilled"), not null
#  paid_federal_extension_payments   :integer          default("unfilled"), not null
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
#  spouse_death_year                 :integer
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
#  unfinished_intake_ids             :text             default([]), is an Array
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

  describe "#sanitize_county_details" do
    context "when updating residence county to designated hurricane relief county" do
      let(:intake) { create :state_file_nc_intake, residence_county: "001", moved_after_hurricane_helene: "yes", county_during_hurricane_helene: "020" }

      it "clears moved_after_hurricane_helene and county_during_hurricane_helene fields" do
        intake.update(residence_county: "011")
        expect(intake.residence_county).to eq "011"
        expect(intake.moved_after_hurricane_helene).to eq "unfilled"
        expect(intake.county_during_hurricane_helene).to eq nil
      end

      context "when didn't move after the hurricane" do
        it "clears the county_during_hurricane_helene field" do
          intake.update(moved_after_hurricane_helene: "no")
          expect(intake.moved_after_hurricane_helene).to eq "no"
          expect(intake.county_during_hurricane_helene).to eq nil
        end
      end
    end

    context "when updating residence county to undesignated hurricane relief county" do
      let(:intake) { create :state_file_nc_intake, residence_county: "001", moved_after_hurricane_helene: "yes", county_during_hurricane_helene: "020" }

      it "doesn't clear moved_after_hurricane_helene and county_during_hurricane_helene fields" do
        intake.update(residence_county: "040")
        expect(intake.residence_county).to eq "040"
        expect(intake.moved_after_hurricane_helene).to eq "yes"
        expect(intake.county_during_hurricane_helene).to eq "020"
      end
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

  describe "#calculate_date_electronic_withdrawal" do
    let(:intake) { create(:state_file_nc_intake, :taxes_owed) }
    let(:state_code) { "nc" }
    let(:timezone) { StateFile::StateInformationService.timezone(state_code) }
    let(:payment_deadline_date) { StateFile::StateInformationService.payment_deadline_date("nc", DateTime.new(filing_year)) }
    let(:utc_offset_hours) { payment_deadline_date.in_time_zone(timezone).utc_offset / 1.hour }
    let(:payment_deadline_datetime) { payment_deadline_date - utc_offset_hours.hours }
    let(:filing_year) { MultiTenantService.new(:statefile).current_tax_year }

    context "when submitted after the payment deadline" do
      it "returns next available date" do
        expect(intake).to receive(:next_available_date)
        intake.calculate_date_electronic_withdrawal(current_time: payment_deadline_datetime + 1.hour)
      end
    end

    context "when submitted before the payment deadline" do
      it "does not call next_available_date" do
        expect(intake).not_to receive(:next_available_date)
        result = intake.calculate_date_electronic_withdrawal(current_time: payment_deadline_datetime - 7.days)
        expect(result).to eq(DateTime.new(2024, 4, 15).in_time_zone(timezone))
      end
    end
  end

  describe '#next_avaliable_date' do
    let(:intake) { create :state_file_nc_intake }
    let(:date) { intake.next_available_date(time) }
    context "when it is before 5pm and the next day is a valid day" do
      # 4pm Tuesday
      let(:time) { DateTime.new(2024, 4, 16, 15, 0, 0) }
      it "is valid and saves the intake with the next day" do
        expect(date).to eq(DateTime.new(2024, 4, 17))
      end
    end

    context "when it is before 5pm and the next day is a holiday" do
      # 4pm christmas eve
      let(:time) { DateTime.new(2024, 12, 24, 15, 0, 0) }
      it "is valid and saves the intake with a date after the holiday" do
        expect(date).to eq(DateTime.new(2024, 12, 26))
      end
    end

    context "when it is before 5pm and the next day is saturday" do
      # 4pm friday
      let(:time) { DateTime.new(2024, 4, 19, 15, 0, 0) }
      it "is valid and saves the intake with a date after the holiday" do
        expect(date).to eq(DateTime.new(2024, 4, 22))
      end
    end

    context "when it is after 5pm and the next two days are valid" do
      # 5:30pm Tuesday
      let(:time) { DateTime.new(2024, 4, 16, 17, 30, 0) }
      it "is valid and saves the intake with a date 2 business days later" do
        expect(date).to eq(DateTime.new(2024, 4, 18))
      end
    end
  end

  describe "#positive_fed_agi?" do
    let(:intake) { create :state_file_nc_intake }
    let(:fed_agi) { 2112 }

    before do
      intake.direct_file_data.fed_agi = fed_agi
    end

    context "when fed agi is positive" do
      let(:fed_agi) { 2112 }

      it "returns true" do
        expect(intake.positive_fed_agi?).to be true
      end
    end

    context "when fed agi is negative" do
      let(:fed_agi) { -5 }

      it "returns false" do
        expect(intake.positive_fed_agi?).to be false
      end
    end

    context "when fed agi is 0" do
      let(:fed_agi) { 0 }

      it "returns false" do
        expect(intake.positive_fed_agi?).to be false
      end
    end
  end
end
