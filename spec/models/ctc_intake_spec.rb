# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default(0), not null
#  already_applied_for_stimulus                         :integer          default(0), not null
#  already_filed                                        :integer          default(0), not null
#  balance_pay_from_bank                                :integer          default(0), not null
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bought_energy_efficient_items                        :integer
#  bought_health_insurance                              :integer          default(0), not null
#  city                                                 :string
#  claimed_by_another                                   :integer          default(0), not null
#  completed_at                                         :datetime
#  completed_yes_no_questions_at                        :datetime
#  continued_at_capacity                                :boolean          default(FALSE)
#  ctc_refund_delivery_method                           :integer
#  current_step                                         :string
#  demographic_disability                               :integer          default(0), not null
#  demographic_english_conversation                     :integer          default(0), not null
#  demographic_english_reading                          :integer          default(0), not null
#  demographic_primary_american_indian_alaska_native    :boolean
#  demographic_primary_asian                            :boolean
#  demographic_primary_black_african_american           :boolean
#  demographic_primary_ethnicity                        :integer          default(0), not null
#  demographic_primary_native_hawaiian_pacific_islander :boolean
#  demographic_primary_prefer_not_to_answer_race        :boolean
#  demographic_primary_white                            :boolean
#  demographic_questions_opt_in                         :integer          default(0), not null
#  demographic_spouse_american_indian_alaska_native     :boolean
#  demographic_spouse_asian                             :boolean
#  demographic_spouse_black_african_american            :boolean
#  demographic_spouse_ethnicity                         :integer          default(0), not null
#  demographic_spouse_native_hawaiian_pacific_islander  :boolean
#  demographic_spouse_prefer_not_to_answer_race         :boolean
#  demographic_spouse_white                             :boolean
#  demographic_veteran                                  :integer          default(0), not null
#  divorced                                             :integer          default(0), not null
#  divorced_year                                        :string
#  eip_only                                             :boolean
#  email_address                                        :citext
#  email_notification_opt_in                            :integer          default("unfilled"), not null
#  encrypted_bank_account_number                        :string
#  encrypted_bank_account_number_iv                     :string
#  encrypted_bank_name                                  :string
#  encrypted_bank_name_iv                               :string
#  encrypted_bank_routing_number                        :string
#  encrypted_bank_routing_number_iv                     :string
#  encrypted_primary_last_four_ssn                      :string
#  encrypted_primary_last_four_ssn_iv                   :string
#  encrypted_primary_ssn                                :string
#  encrypted_primary_ssn_iv                             :string
#  encrypted_spouse_last_four_ssn                       :string
#  encrypted_spouse_last_four_ssn_iv                    :string
#  encrypted_spouse_ssn                                 :string
#  encrypted_spouse_ssn_iv                              :string
#  ever_married                                         :integer          default(0), not null
#  ever_owned_home                                      :integer          default(0), not null
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default(0), not null
#  filing_for_stimulus                                  :integer          default(0), not null
#  filing_joint                                         :integer          default(0), not null
#  final_info                                           :string
#  had_asset_sale_income                                :integer          default(0), not null
#  had_debt_forgiven                                    :integer          default(0), not null
#  had_dependents                                       :integer          default(0), not null
#  had_disability                                       :integer          default(0), not null
#  had_disability_income                                :integer          default(0), not null
#  had_disaster_loss                                    :integer          default(0), not null
#  had_farm_income                                      :integer          default(0), not null
#  had_gambling_income                                  :integer          default(0), not null
#  had_hsa                                              :integer          default(0), not null
#  had_interest_income                                  :integer          default(0), not null
#  had_local_tax_refund                                 :integer          default(0), not null
#  had_other_income                                     :integer          default(0), not null
#  had_rental_income                                    :integer          default(0), not null
#  had_retirement_income                                :integer          default(0), not null
#  had_self_employment_income                           :integer          default(0), not null
#  had_social_security_income                           :integer          default(0), not null
#  had_social_security_or_retirement                    :integer          default(0), not null
#  had_student_in_family                                :integer          default(0), not null
#  had_tax_credit_disallowed                            :integer          default(0), not null
#  had_tips                                             :integer          default(0), not null
#  had_unemployment_income                              :integer          default(0), not null
#  had_wages                                            :integer          default(0), not null
#  income_over_limit                                    :integer          default(0), not null
#  interview_timing_preference                          :string
#  issued_identity_pin                                  :integer          default(0), not null
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default(0), not null
#  locale                                               :string
#  made_estimated_tax_payments                          :integer          default(0), not null
#  married                                              :integer          default(0), not null
#  multiple_states                                      :integer          default(0), not null
#  navigator_has_verified_client_identity               :boolean
#  navigator_name                                       :string
#  needs_help_2016                                      :integer          default(0), not null
#  needs_help_2017                                      :integer          default(0), not null
#  needs_help_2018                                      :integer          default(0), not null
#  needs_help_2019                                      :integer          default(0), not null
#  needs_help_2020                                      :integer          default(0), not null
#  needs_to_flush_searchable_data_set_at                :datetime
#  no_eligibility_checks_apply                          :integer          default(0), not null
#  no_ssn                                               :integer          default(0), not null
#  other_income_types                                   :string
#  paid_alimony                                         :integer          default(0), not null
#  paid_charitable_contributions                        :integer          default(0), not null
#  paid_dependent_care                                  :integer          default(0), not null
#  paid_local_tax                                       :integer          default(0), not null
#  paid_medical_expenses                                :integer          default(0), not null
#  paid_mortgage_interest                               :integer          default(0), not null
#  paid_retirement_contributions                        :integer          default(0), not null
#  paid_school_supplies                                 :integer          default(0), not null
#  paid_student_loan_interest                           :integer          default(0), not null
#  phone_number                                         :string
#  phone_number_can_receive_texts                       :integer          default(0), not null
#  preferred_interview_language                         :string
#  preferred_name                                       :string
#  primary_birth_date                                   :date
#  primary_consented_to_service                         :integer          default("unfilled"), not null
#  primary_consented_to_service_at                      :datetime
#  primary_consented_to_service_ip                      :inet
#  primary_first_name                                   :string
#  primary_ip_pin                                       :integer
#  primary_last_name                                    :string
#  received_alimony                                     :integer          default(0), not null
#  received_homebuyer_credit                            :integer          default(0), not null
#  received_irs_letter                                  :integer          default(0), not null
#  received_stimulus_payment                            :integer          default(0), not null
#  eip1_amount_received                      :integer
#  eip2_amount_received                      :integer
#  eip1_and_2_amount_received_confidence             :integer
#  referrer                                             :string
#  refund_payment_method                                :integer          default(0), not null
#  reported_asset_sale_loss                             :integer          default(0), not null
#  reported_self_employment_loss                        :integer          default(0), not null
#  requested_docs_token                                 :string
#  requested_docs_token_created_at                      :datetime
#  routed_at                                            :datetime
#  routing_criteria                                     :string
#  routing_value                                        :string
#  satisfaction_face                                    :integer          default(0), not null
#  savings_purchase_bond                                :integer          default(0), not null
#  savings_split_refund                                 :integer          default(0), not null
#  searchable_data                                      :tsvector
#  separated                                            :integer          default(0), not null
#  separated_year                                       :string
#  signature_method                                     :integer          default("online"), not null
#  sms_notification_opt_in                              :integer          default("unfilled"), not null
#  sms_phone_number                                     :string
#  sold_a_home                                          :integer          default(0), not null
#  sold_assets                                          :integer          default(0), not null
#  source                                               :string
#  spouse_auth_token                                    :string
#  spouse_birth_date                                    :date
#  spouse_consented_to_service                          :integer          default(0), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :citext
#  spouse_first_name                                    :string
#  spouse_had_disability                                :integer          default(0), not null
#  spouse_ip_pin                                        :integer
#  spouse_issued_identity_pin                           :integer          default(0), not null
#  spouse_last_name                                     :string
#  spouse_was_blind                                     :integer          default(0), not null
#  spouse_was_full_time_student                         :integer          default(0), not null
#  spouse_was_on_visa                                   :integer          default(0), not null
#  state                                                :string
#  state_of_residence                                   :string
#  street_address                                       :string
#  timezone                                             :string
#  triage_source_type                                   :string
#  type                                                 :string
#  viewed_at_capacity                                   :boolean          default(FALSE)
#  vita_partner_name                                    :string
#  wants_to_itemize                                     :integer          default(0), not null
#  was_blind                                            :integer          default(0), not null
#  was_full_time_student                                :integer          default(0), not null
#  was_on_visa                                          :integer          default(0), not null
#  widowed                                              :integer          default(0), not null
#  widowed_year                                         :string
#  with_general_navigator                               :boolean          default(FALSE)
#  with_incarcerated_navigator                          :boolean          default(FALSE)
#  with_limited_english_navigator                       :boolean          default(FALSE)
#  with_unhoused_navigator                              :boolean          default(FALSE)
#  zip_code                                             :string
#  created_at                                           :datetime
#  updated_at                                           :datetime
#  client_id                                            :bigint
#  triage_source_id                                     :bigint
#  visitor_id                                           :string
#  vita_partner_id                                      :bigint
#  with_drivers_license_photo_id                        :boolean          default(FALSE)
#  with_itin_taxpayer_id                                :boolean          default(FALSE)
#  with_other_state_photo_id                            :boolean          default(FALSE)
#  with_passport_photo_id                               :boolean          default(FALSE)
#  with_social_security_taxpayer_id                     :boolean          default(FALSE)
#  with_vita_approved_photo_id                          :boolean          default(FALSE)
#  with_vita_approved_taxpayer_id                       :boolean          default(FALSE)
#
# Indexes
#
#  index_intakes_on_client_id                                (client_id)
#  index_intakes_on_email_address                            (email_address)
#  index_intakes_on_needs_to_flush_searchable_data_set_at    (needs_to_flush_searchable_data_set_at) WHERE (needs_to_flush_searchable_data_set_at IS NOT NULL)
#  index_intakes_on_phone_number                             (phone_number)
#  index_intakes_on_searchable_data                          (searchable_data) USING gin
#  index_intakes_on_sms_phone_number                         (sms_phone_number)
#  index_intakes_on_triage_source_type_and_triage_source_id  (triage_source_type,triage_source_id)
#  index_intakes_on_vita_partner_id                          (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#

require "rails_helper"

describe Intake::CtcIntake, requires_default_vita_partners: true do
  describe ".accessible_intakes" do
    context "when no verification has occurred" do
      let!(:intake) { create :ctc_intake }
      it "is not accessible" do
        expect(described_class.accessible_intakes).not_to include intake
      end
    end

    context "when sms verification has occured" do
      let!(:intake) { create :ctc_intake, sms_phone_number_verified_at: DateTime.now }
      it "is accessible" do
        expect(described_class.accessible_intakes).to include intake
      end
    end

    context "when sms verification has occurred" do
      let!(:intake) { create :ctc_intake, email_address_verified_at: DateTime.now }
      it "is accessible" do
        expect(described_class.accessible_intakes).to include intake
      end
    end

    context "when navigator verification has occurred" do
      let!(:intake) { create :ctc_intake, navigator_has_verified_client_identity: true }
      it "is accessible" do
        expect(described_class.accessible_intakes).to include intake
      end
    end
  end

  describe "#duplicates" do
    let(:dupe_double) { double }
    before do
      allow(DeduplificationService).to receive(:duplicates).and_return dupe_double
      allow(dupe_double).to receive(:or)
    end

    context "when hashed primary ssn is present" do
      let(:intake) { create :ctc_intake, hashed_primary_ssn: "123456789" }
      it "builds a query looking for duplicates" do
        intake.duplicates
        expect(DeduplificationService).to have_received(:duplicates).exactly(1).times.with(intake, :hashed_primary_ssn, from_scope: described_class.accessible_intakes)
      end
    end

    context "when hashed primary ssn is not present" do
      let(:intake) { create :ctc_intake, hashed_primary_ssn: nil }
      it "responds with an empty collection" do
        expect(intake.duplicates).to eq described_class.none
      end
    end
  end

  describe "#any_ip_pins?" do
    context "when any member of household has an IP PIN" do
      let(:intake) { create :ctc_intake, dependents: [ create(:dependent, ssn: '111-22-3333', ip_pin: 123456) ] }

      it "returns true" do
        expect(intake.any_ip_pins?).to eq true
      end
    end

    context "when no member of household has an IP PIN" do
      let(:intake) { create :ctc_intake }

      it "returns false" do
        expect(intake.any_ip_pins?).to eq false
      end
    end
  end

  describe "#spouse_prior_year_agi_amount_computed" do
    let(:spouse_filed_prior_tax_year) { :unfilled }
    let(:intake) {
      build :ctc_intake,
        spouse_filed_prior_tax_year: spouse_filed_prior_tax_year,
        primary_prior_year_agi_amount: 123,
        spouse_prior_year_agi_amount: 987
    }

    context "did not file" do
      let(:spouse_filed_prior_tax_year) { :did_not_file }

      it 'returns 0' do
        expect(intake.spouse_prior_year_agi_amount_computed).to eq 0
      end
    end

    context "filed separately (full return)" do
      let(:spouse_filed_prior_tax_year) { :filed_full_separate }

      it 'returns the spouse_prior_year_agi_amount' do
        expect(intake.spouse_prior_year_agi_amount_computed).to eq 987
      end
    end

    context "filed separately (non-filer)" do
      let(:spouse_filed_prior_tax_year) { :filed_non_filer_separate }

      it 'returns 1' do
        expect(intake.spouse_prior_year_agi_amount_computed).to eq 1
      end
    end

    context "filed together" do
      let(:spouse_filed_prior_tax_year) { :filed_together }

      it "returns primary_prior_year_agi_amount" do
        expect(intake.spouse_prior_year_agi_amount_computed).to eq 123
      end
    end
  end

  context "before_validation" do
    context "normalize spaces in names" do
      let(:intake) {
        build :ctc_intake,
          primary_first_name: "Anna  Marie",
          primary_last_name: "Apple   Mango",
          spouse_first_name: "Roberta    Margaret",
          spouse_last_name: "Raspberry   Melon"
      }

      it "makes sure names with spaces only have one space between each name" do
        intake.valid?

        expect(intake.primary_first_name).to eq "Anna Marie"
        expect(intake.primary_last_name).to eq "Apple Mango"
        expect(intake.spouse_first_name).to eq "Roberta Margaret"
        expect(intake.spouse_last_name).to eq "Raspberry Melon"
      end
    end
  end

  describe "#eitc_qualifications_passes_age_test?" do
    context "when they are over 24" do
      #  they qualify
    end

    context "when they are under 24" do
      context "when they have at least one qualifying child" do
        #  they qualify
      end

      context "when they have no qualifying children" do
        # if they are a qualified former foster youth or qualified homeless youth, they must be at least 18 on 12/31/2021 (otherwise, they cannot claim the EITC). Show them the offboarding page
        context "they are a former foster or homeless youth" do
          context "they were at least 18 on 12/31/2021" do
            #  they qualify
          end

          context "they were not at least 18 on 12/31/2021" do
            #  they do not qualify
          end
        end

        # if they were a full-time student for 4 months of fewer or were NOT a full-time student, they must be at least 19 on 12/31/2021 (otherwise, they cannot claim the EITC). Show them the offboarding page
        context "they are not a full time student or were a full time student for 4 months or fewer" do
          context "they were at least 19 on 12/31/2021" do
            #  they qualify
          end

          context "they were not at least 19 on 12/31/2021" do
            #  they do not qualify
          end
        end
      end
    end
  end

  describe "#qualified_for_eitc?" do
    let(:intake) { create(:ctc_intake, exceeded_investment_income_limit: exceeded_investment_income_limit) }

    before do
      Flipper.enable(:eitc)
    end

    context "when they do not pass investment income test or age test" do
      let(:exceeded_investment_income_limit) { "yes" }

      before do
        allow(intake).to receive(:eitc_qualifications_passes_age_test?).and_return false
      end

      it "returns false" do
        expect(intake.qualified_for_eitc?).to eq false
      end
    end

    context "they pass investment income test and age test" do
      let(:exceeded_investment_income_limit) { "no" }

      before do
        allow(intake).to receive(:eitc_qualifications_passes_age_test?).and_return true
      end

      it "returns true" do
        expect(intake.qualified_for_eitc?).to eq true
      end
    end

  #  TODO: test all combinations?
  end
end
