# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default("unfilled"), not null
#  already_filed                                        :integer          default("unfilled"), not null
#  anonymous                                            :boolean          default(FALSE), not null
#  balance_pay_from_bank                                :integer          default("unfilled"), not null
#  bank_account_type                                    :integer          default("unfilled"), not null
#  bought_energy_efficient_items                        :integer
#  bought_health_insurance                              :integer          default("unfilled"), not null
#  city                                                 :string
#  completed_at                                         :datetime
#  completed_intake_sent_to_zendesk                     :boolean
#  continued_at_capacity                                :boolean          default(FALSE)
#  demographic_disability                               :integer          default("unfilled"), not null
#  demographic_english_conversation                     :integer          default("unfilled"), not null
#  demographic_english_reading                          :integer          default("unfilled"), not null
#  demographic_primary_american_indian_alaska_native    :boolean
#  demographic_primary_asian                            :boolean
#  demographic_primary_black_african_american           :boolean
#  demographic_primary_ethnicity                        :integer          default("unfilled"), not null
#  demographic_primary_native_hawaiian_pacific_islander :boolean
#  demographic_primary_prefer_not_to_answer_race        :boolean
#  demographic_primary_white                            :boolean
#  demographic_questions_opt_in                         :integer          default("unfilled"), not null
#  demographic_spouse_american_indian_alaska_native     :boolean
#  demographic_spouse_asian                             :boolean
#  demographic_spouse_black_african_american            :boolean
#  demographic_spouse_ethnicity                         :integer          default("unfilled"), not null
#  demographic_spouse_native_hawaiian_pacific_islander  :boolean
#  demographic_spouse_prefer_not_to_answer_race         :boolean
#  demographic_spouse_white                             :boolean
#  demographic_veteran                                  :integer          default("unfilled"), not null
#  divorced                                             :integer          default("unfilled"), not null
#  divorced_year                                        :string
#  email_address                                        :string
#  email_notification_opt_in                            :integer          default("unfilled"), not null
#  encrypted_bank_account_number                        :string
#  encrypted_bank_account_number_iv                     :string
#  encrypted_bank_name                                  :string
#  encrypted_bank_name_iv                               :string
#  encrypted_bank_routing_number                        :string
#  encrypted_bank_routing_number_iv                     :string
#  encrypted_primary_last_four_ssn                      :string
#  encrypted_primary_last_four_ssn_iv                   :string
#  encrypted_spouse_last_four_ssn                       :string
#  encrypted_spouse_last_four_ssn_iv                    :string
#  ever_married                                         :integer          default("unfilled"), not null
#  feedback                                             :string
#  feeling_about_taxes                                  :integer          default("unfilled"), not null
#  filing_for_stimulus                                  :integer          default("unfilled"), not null
#  filing_joint                                         :integer          default("unfilled"), not null
#  final_info                                           :string
#  had_asset_sale_income                                :integer          default("unfilled"), not null
#  had_debt_forgiven                                    :integer          default("unfilled"), not null
#  had_dependents                                       :integer          default("unfilled"), not null
#  had_disability                                       :integer          default("unfilled"), not null
#  had_disability_income                                :integer          default("unfilled"), not null
#  had_disaster_loss                                    :integer          default("unfilled"), not null
#  had_farm_income                                      :integer          default("unfilled"), not null
#  had_gambling_income                                  :integer          default("unfilled"), not null
#  had_hsa                                              :integer          default("unfilled"), not null
#  had_interest_income                                  :integer          default("unfilled"), not null
#  had_local_tax_refund                                 :integer          default("unfilled"), not null
#  had_other_income                                     :integer          default("unfilled"), not null
#  had_rental_income                                    :integer          default("unfilled"), not null
#  had_retirement_income                                :integer          default("unfilled"), not null
#  had_self_employment_income                           :integer          default("unfilled"), not null
#  had_social_security_income                           :integer          default("unfilled"), not null
#  had_student_in_family                                :integer          default("unfilled"), not null
#  had_tax_credit_disallowed                            :integer          default("unfilled"), not null
#  had_tips                                             :integer          default("unfilled"), not null
#  had_unemployment_income                              :integer          default("unfilled"), not null
#  had_wages                                            :integer          default("unfilled"), not null
#  income_over_limit                                    :integer          default("unfilled"), not null
#  intake_pdf_sent_to_zendesk                           :boolean          default(FALSE), not null
#  interview_timing_preference                          :string
#  issued_identity_pin                                  :integer          default("unfilled"), not null
#  job_count                                            :integer
#  lived_with_spouse                                    :integer          default("unfilled"), not null
#  locale                                               :string
#  made_estimated_tax_payments                          :integer          default("unfilled"), not null
#  married                                              :integer          default("unfilled"), not null
#  multiple_states                                      :integer          default("unfilled"), not null
#  needs_help_2016                                      :integer          default("unfilled"), not null
#  needs_help_2017                                      :integer          default("unfilled"), not null
#  needs_help_2018                                      :integer          default("unfilled"), not null
#  needs_help_2019                                      :integer          default("unfilled"), not null
#  no_eligibility_checks_apply                          :integer          default("unfilled"), not null
#  other_income_types                                   :string
#  paid_alimony                                         :integer          default("unfilled"), not null
#  paid_charitable_contributions                        :integer          default("unfilled"), not null
#  paid_dependent_care                                  :integer          default("unfilled"), not null
#  paid_local_tax                                       :integer          default("unfilled"), not null
#  paid_medical_expenses                                :integer          default("unfilled"), not null
#  paid_mortgage_interest                               :integer          default("unfilled"), not null
#  paid_retirement_contributions                        :integer          default("unfilled"), not null
#  paid_school_supplies                                 :integer          default("unfilled"), not null
#  paid_student_loan_interest                           :integer          default("unfilled"), not null
#  phone_number                                         :string
#  phone_number_can_receive_texts                       :integer          default("unfilled"), not null
#  preferred_interview_language                         :string
#  preferred_name                                       :string
#  primary_birth_date                                   :date
#  primary_consented_to_service                         :integer          default("unfilled"), not null
#  primary_consented_to_service_at                      :datetime
#  primary_consented_to_service_ip                      :inet
#  primary_first_name                                   :string
#  primary_last_name                                    :string
#  received_alimony                                     :integer          default("unfilled"), not null
#  received_homebuyer_credit                            :integer          default("unfilled"), not null
#  received_irs_letter                                  :integer          default("unfilled"), not null
#  referrer                                             :string
#  refund_payment_method                                :integer          default("unfilled"), not null
#  reported_asset_sale_loss                             :integer          default("unfilled"), not null
#  reported_self_employment_loss                        :integer          default("unfilled"), not null
#  requested_docs_token                                 :string
#  requested_docs_token_created_at                      :datetime
#  routed_at                                            :datetime
#  routing_criteria                                     :string
#  routing_value                                        :string
#  satisfaction_face                                    :integer          default("unfilled"), not null
#  savings_purchase_bond                                :integer          default("unfilled"), not null
#  savings_split_refund                                 :integer          default("unfilled"), not null
#  separated                                            :integer          default("unfilled"), not null
#  separated_year                                       :string
#  sms_notification_opt_in                              :integer          default("unfilled"), not null
#  sms_phone_number                                     :string
#  sold_a_home                                          :integer          default("unfilled"), not null
#  source                                               :string
#  spouse_auth_token                                    :string
#  spouse_birth_date                                    :date
#  spouse_consented_to_service                          :integer          default("unfilled"), not null
#  spouse_consented_to_service_at                       :datetime
#  spouse_consented_to_service_ip                       :inet
#  spouse_email_address                                 :string
#  spouse_first_name                                    :string
#  spouse_had_disability                                :integer          default("unfilled"), not null
#  spouse_issued_identity_pin                           :integer          default("unfilled"), not null
#  spouse_last_name                                     :string
#  spouse_was_blind                                     :integer          default("unfilled"), not null
#  spouse_was_full_time_student                         :integer          default("unfilled"), not null
#  spouse_was_on_visa                                   :integer          default("unfilled"), not null
#  state                                                :string
#  state_of_residence                                   :string
#  street_address                                       :string
#  timezone                                             :string
#  triage_source_type                                   :string
#  viewed_at_capacity                                   :boolean          default(FALSE)
#  vita_partner_name                                    :string
#  was_blind                                            :integer          default("unfilled"), not null
#  was_full_time_student                                :integer          default("unfilled"), not null
#  was_on_visa                                          :integer          default("unfilled"), not null
#  widowed                                              :integer          default("unfilled"), not null
#  widowed_year                                         :string
#  zendesk_instance_domain                              :string
#  zip_code                                             :string
#  created_at                                           :datetime
#  updated_at                                           :datetime
#  intake_ticket_id                                     :bigint
#  intake_ticket_requester_id                           :bigint
#  primary_intake_id                                    :integer
#  triage_source_id                                     :bigint
#  visitor_id                                           :string
#  vita_partner_group_id                                :string
#  vita_partner_id                                      :bigint
#
# Indexes
#
#  index_intakes_on_triage_source_type_and_triage_source_id  (triage_source_type,triage_source_id)
#  index_intakes_on_vita_partner_id                          (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#

require 'rails_helper'

describe Intake do
  describe ".create_anonymous_intake" do
    let(:original_intake) { create :intake,
                                   intake_ticket_id: 123,
                                   visitor_id: "ABC987",
                                   anonymous: false,
                                   referrer: "https://coolsite.org"
    }
    it "returns an intake with select data copied from the original intake" do
      anonymous_intake = Intake.create_anonymous_intake(original_intake)

      expect(anonymous_intake.intake_ticket_id).to eq 123
      expect(anonymous_intake.visitor_id).to eq "ABC987"
    end

    it "returns an intake with the anonymous field set to true" do
      anonymous_intake = Intake.create_anonymous_intake(original_intake)

      expect(anonymous_intake.anonymous).to eq true
    end
  end

  describe ".find_original_intake" do
    let!(:original_intake) { create :intake, intake_ticket_id: 123, visitor_id: "ABC987", anonymous: false, created_at: 5.days.ago }
    let!(:anonymous_intake) { create :intake, intake_ticket_id: 123, visitor_id: "ABC987", anonymous: true }

    it "returns the oldest intake with a matching ticket ID where anonymous is false" do
      intake = Intake.find_original_intake(anonymous_intake)

      expect(intake).to eq original_intake
    end

    context "when multiple original intakes match the ticket ID" do
      let!(:older_intake) { create :intake, intake_ticket_id: 123, visitor_id: "ABC987", anonymous: false, created_at: 7.days.ago }

      it "returns the oldest matching non-anonymous intake" do
        intake = Intake.find_original_intake(anonymous_intake)

        expect(intake).to eq older_intake
      end
    end
  end

  describe ".find_for_requested_docs_token" do
    let!(:original_intake) { create :intake, requested_docs_token: "ABC987", anonymous: false }
    let!(:anonymous_intake) { create :intake, requested_docs_token: "ABC987", anonymous: true }

    it "returns the first non-anonymous intake with a matching token" do
      intake = Intake.find_for_requested_docs_token("ABC987")

      expect(intake).to eq original_intake
      expect(intake.anonymous).to eq false
    end
  end

  describe "#pdf" do
    let(:intake) { create :intake }
    let(:intake_pdf_spy) { instance_double(IntakePdf) }

    before do
      allow(IntakePdf).to receive(:new).with(intake).and_return(intake_pdf_spy)
      allow(intake_pdf_spy).to receive(:output_file).and_return("i am a pdf")
    end

    it "generates a 13614c pdf for this intake" do
      result = intake.pdf

      expect(IntakePdf).to have_received(:new).with(intake)
      expect(intake_pdf_spy).to have_received(:output_file)
      expect(result).to eq "i am a pdf"
    end
  end

  describe "#consent_pdf" do
    let(:intake) { create :intake }
    let(:consent_pdf_spy) { instance_double(ConsentPdf) }

    before do
      allow(ConsentPdf).to receive(:new).with(intake).and_return(consent_pdf_spy)
      allow(consent_pdf_spy).to receive(:output_file).and_return("i am a pdf")
    end

    it "generates a consent pdf for this intake" do
      result = intake.consent_pdf

      expect(ConsentPdf).to have_received(:new).with(intake)
      expect(consent_pdf_spy).to have_received(:output_file)
      expect(result).to eq "i am a pdf"
    end
  end

  describe "#bank_details_png" do
    let(:intake) { create :intake }
    let(:bank_details_pdf_spy) { instance_double(BankDetailsPdf) }

    before do
      allow(BankDetailsPdf).to receive(:new).with(intake).and_return(bank_details_pdf_spy)
      allow(bank_details_pdf_spy).to receive(:as_png).and_return("i am a png")
    end

    it "generates a bank details png for this intake" do
      result = intake.bank_details_png

      expect(BankDetailsPdf).to have_received(:new).with(intake)
      expect(bank_details_pdf_spy).to have_received(:as_png)
      expect(result).to eq "i am a png"
    end
  end

  describe "#users" do
    it "should have many users" do
      relation = Intake.reflect_on_association(:users).macro
      expect(relation).to eq :has_many
    end
  end

  describe "#primary_user" do
    let(:intake) { create :intake }

    context "with no user" do
      it "returns nil" do
        expect(intake.primary_user).to be_nil
      end
    end

    context "with one user" do
      let!(:primary) { create :idme_user, intake: intake }

      it "returns that one user" do
        expect(intake.primary_user).to eq primary
      end
    end
  end

  describe "#referrer_domain" do
    let(:intake) { build :intake, referrer: referrer }

    context "with a referrer" do
      let(:referrer) { "https://www.google.com/some/stuffs?id=whocares" }

      it "returns the domain from the referrer" do
        expect(intake.referrer_domain).to eq "www.google.com"
      end
    end

    context "with no referrer" do
      let(:referrer) { nil }

      it "returns the domain from the referrer" do
        expect(intake.referrer_domain).to be_nil
      end
    end
  end

  describe "#any_students?" do
    context "without answers" do
      let(:intake) { build :intake }

      it "returns false" do
        expect(intake.any_students?).to eq false
      end
    end

    context "when the primary user says they are not a student" do
      let(:intake) do
        build :intake, was_full_time_student: "no"
      end

      it "returns false" do
        expect(intake.any_students?).to eq false
      end
    end

    context "when the primary user says they are a full time student" do
      let(:intake) do
        build :intake, was_full_time_student: "yes", spouse_was_full_time_student: "no"
      end

      it "returns true" do
        expect(intake.any_students?).to eq true
      end
    end

    context "when a dependent is marked as a student" do
      let(:intake) { create :intake }
      before { create :dependent, intake: intake, was_student: "yes" }

      it "returns true" do
        expect(intake.any_students?).to eq true
      end
    end

    context "when they said someone was a student" do
      let(:intake) { create :intake, had_student_in_family: "yes" }

      it "returns true" do
        expect(intake.any_students?).to eq true
      end
    end
  end

  describe "#student_names" do
    context "when everyone is a student" do
      let(:intake) do
        create :intake,
          was_full_time_student: "yes",
          spouse_was_full_time_student: "yes",
          primary_first_name: "Henrietta",
          primary_last_name: "Huckleberry",
          spouse_first_name: "Helga",
          spouse_last_name: "Huckleberry"
      end
      before do
        create :dependent, intake: intake, first_name: "Harriet", last_name: "Huckleberry", was_student: "yes"
        create :dependent, intake: intake, first_name: "Henry", last_name: "Huckleberry", was_student: "yes"
      end

      it "returns all the names" do
        expected_results = [
          "Henrietta Huckleberry",
          "Helga Huckleberry",
          "Harriet Huckleberry",
          "Henry Huckleberry",
        ]
        expect(intake.student_names).to eq(expected_results)
      end
    end

    context "when only one dependent is a student" do
      let(:intake) do
        create :intake,
          was_full_time_student: "no",
          spouse_was_full_time_student: "unfilled",
          primary_first_name: "Henrietta",
          primary_last_name: "Huckleberry",
          spouse_first_name: "Helga",
          spouse_last_name: "Huckleberry"
      end

      before do
        create :dependent, intake: intake, first_name: "Harriet", last_name: "Huckleberry", was_student: "yes"
        create :dependent, intake: intake, first_name: "Henry", last_name: "Huckleberry", was_student: "no"
      end

      it "returns only one name" do
        expected_results = [
          "Harriet Huckleberry",
        ]
        expect(intake.student_names).to eq(expected_results)
      end
    end

    context "when no one is a student" do
      let(:intake) do
        create :intake,
          was_full_time_student: "no",
          spouse_was_full_time_student: "no",
          primary_first_name: "Henrietta",
          primary_last_name: "Huckleberry",
          spouse_first_name: "Helga",
          spouse_last_name: "Huckleberry"
      end

      before do
        create :dependent, intake: intake, first_name: "Harriet", last_name: "Huckleberry", was_student: "no"
        create :dependent, intake: intake, first_name: "Henry", last_name: "Huckleberry", was_student: "no"
      end

      it "returns an empty array" do
        expect(intake.student_names).to eq([])
      end
    end

    context "when there is no spouse verified but the spouse was a student" do
      let(:intake) do
        create :intake,
          was_full_time_student: "yes",
          spouse_was_full_time_student: "yes",
          primary_first_name: "Henrietta",
          primary_last_name: "Huckleberry"
      end

      it "shows a placeholder for the spouse name" do
        expect(intake.student_names).to eq(["Henrietta Huckleberry", "Your spouse"])
      end
    end
  end

  describe "#external_id" do
    let(:intake) { build :intake }

    context "when unsaved" do
      it "is nil" do
        expect(intake.external_id).to eq(nil)
      end
    end

    context "when saved" do
      it "is in the intended format" do
        intake.save
        intake.reload
        expect(intake.external_id).to eq("intake-#{intake.id}")
      end
    end
  end

  describe "#get_or_create_spouse_auth_token" do
    let(:intake) { build :intake, spouse_auth_token: existing_token }
    let(:new_token) { "n3wt0k3n" }
    before do
      allow(SecureRandom).to receive(:urlsafe_base64).with(8).and_return(new_token)
    end

    context "when a spouse auth token does not yet exist" do
      let(:existing_token) { nil }

      it "generates the token and returns it" do
        result = intake.get_or_create_spouse_auth_token
        expect(result).to eq new_token
        expect(intake.spouse_auth_token).to eq new_token
        expect(SecureRandom).to have_received(:urlsafe_base64).with(8)
      end
    end

    context "when the token already exists" do
      let(:existing_token) { "3x1st1ngT0k3n" }

      it "just returns the token and does not generate a new one" do
        result = intake.get_or_create_spouse_auth_token
        expect(result).to eq existing_token
        expect(intake.spouse_auth_token).to eq existing_token
        expect(SecureRandom).not_to have_received(:urlsafe_base64)
      end
    end
  end

  describe "#get_or_create_requested_docs_token" do
    let(:intake) { build :intake, requested_docs_token: existing_token, requested_docs_token_created_at: token_created_at }
    let(:new_token) { "n3wt0k3n" }
    before do
      allow(SecureRandom).to receive(:urlsafe_base64).with(10).and_return(new_token)
    end

    context "when a spouse auth token does not yet exist" do
      let(:existing_token) { nil }
      let(:token_created_at) { nil }

      it "generates the token and returns it" do
        result = intake.get_or_create_requested_docs_token
        expect(result).to eq new_token
        expect(intake.requested_docs_token).to eq new_token
        expect(SecureRandom).to have_received(:urlsafe_base64).with(10)
        expect(intake.requested_docs_token_created_at).to be_within(2.seconds).of(Time.now)
      end
    end

    context "when the token already exists" do
      let(:existing_token) { "3x1st1ngT0k3n" }
      let(:token_created_at) { 3.days.ago }

      it "just returns the token and does not generate a new one" do
        result = intake.get_or_create_requested_docs_token
        expect(result).to eq existing_token
        expect(intake.requested_docs_token).to eq existing_token
        expect(SecureRandom).not_to have_received(:urlsafe_base64)
        expect(intake.requested_docs_token_created_at).to eq token_created_at
      end
    end
  end

  describe "#filing_years" do
    let(:intake) { create :intake, **filing_years }
    let(:filing_years) { {} }

    context "with unfilled filing years" do
      it "returns empty array" do
        expect(intake.filing_years).to eq([])
      end
    end

    context "with a couple filing years selected" do
      let(:filing_years) do
        {
          needs_help_2019: "yes",
          needs_help_2018: "no",
          needs_help_2017: "unfilled",
        }
      end

      it "returns them as an array" do
        expect(intake.filing_years).to eq(["2019"])
      end
    end
  end

  describe "#most_recent_filing_year" do
    let(:intake) { create :intake, **filing_years }
    let(:filing_years) { {} }

    context "with unfilled filing years" do
      it "returns nil" do
        expect(intake.most_recent_filing_year).to be_nil
      end
    end

    context "when multiple years are selected" do
      let(:filing_years) do
        {
          needs_help_2019: "yes",
          needs_help_2018: "no",
          needs_help_2017: "unfilled",
        }
      end

      it "returns most recent" do
        expect(intake.most_recent_filing_year).to eq("2019")
      end
    end

    context "when 2019 is not selected" do
      let(:filing_years) do
        {
          needs_help_2019: "no",
          needs_help_2018: "yes",
          needs_help_2017: "unfilled",
        }
      end

      it "returns next most recent" do
        expect(intake.most_recent_filing_year).to eq("2018")
      end
    end
  end

  describe "#year_before_most_recent_filing_year" do
    let(:intake) { create :intake, **filing_years }
    let(:filing_years) { {} }

    context "with unfilled filing years" do
      it "returns nil" do
        expect(intake.year_before_most_recent_filing_year).to be_nil
      end
    end

    context "when a year is selected" do
      let(:filing_years) do
        {
          needs_help_2019: "no",
          needs_help_2018: "yes",
          needs_help_2017: "unfilled",
        }
      end

      it "returns most recent" do
        expect(intake.year_before_most_recent_filing_year).to eq("2017")
      end
    end
  end

  describe "#zendesk_instance" do
    context "when the intake has a zendesk_instance_domain value saved in the DB" do
      let(:eitc_intake) { create :intake, zendesk_instance_domain: "eitc" }
      let(:uwtsa_intake) { create :intake, zendesk_instance_domain: "unitedwaytucson" }

      it "returns the corresponding instance" do
        expect(eitc_intake.zendesk_instance).to eq (EitcZendeskInstance)
        expect(uwtsa_intake.zendesk_instance).to eq (UwtsaZendeskInstance)
      end
    end

    context "when the zendesk_instance_domain is nil" do
      context "when the state is nil" do
        let(:intake) { create :intake }

        it "returns the eitc instance and saves the domain on the intake" do
          expect(intake.zendesk_instance).to eq (EitcZendeskInstance)
          expect(intake.reload.zendesk_instance_domain).to eq ("eitc")
        end
      end

      context "when the group id is an EITC group id" do
        let(:intake) { create :intake, state: "oh", source: "uwco" }

        it "returns the eitc instance and saves the domain on the intake" do
          expect(intake.zendesk_instance).to eq (EitcZendeskInstance)
          expect(intake.reload.zendesk_instance_domain).to eq ("eitc")
        end
      end

      context "when the group id is NOT an EITC group id" do
        let(:intake) { create :intake, state_of_residence: "ny", source: nil }

        it "returns the EITC instance and saves the domain on the intake" do
          expect(intake.zendesk_instance).to eq (EitcZendeskInstance)
          expect(intake.reload.zendesk_instance_domain).to eq ("eitc")
        end
      end
    end
  end

  describe "Zendesk routing" do
    let(:source) { nil }
    let(:intake) { create :intake, state_of_residence: state, source: source }

    context "when the zendesk instance domain has been saved as UWTSA instance" do
      let(:uwtsa_instance_intake) { create :intake, state_of_residence: "az", zendesk_instance_domain: UwtsaZendeskInstance::DOMAIN}

      it "assigns to the UWTSA instance and nil group id" do
        expect(uwtsa_instance_intake.reload.vita_partner_group_id).to eq nil
        expect(uwtsa_instance_intake.zendesk_instance).to eq UwtsaZendeskInstance
      end
    end

    context "when there is a source parameter" do
      shared_examples :source_group_matching do |src, expected_group_id|
        let(:state) { "ne" }

        before do
          intake.assign_vita_partner!
        end

        context "source matches an organization" do
          let(:source) { src }

          it "assigns to the correct group and the correct instance" do
            expect(intake.reload.vita_partner_group_id).to eq expected_group_id
            expect(intake.zendesk_instance).to eq EitcZendeskInstance
          end
        end

        context "source matches a key but is weirdly cased" do
          let(:source) do
            src.chars.map { |c| [true, false].sample ? c.downcase : c.upcase }.join
            # latergram: this is kinda awesome
          end

          it "assigns to the correct group and the correct instance" do
            expect(intake.reload.vita_partner_group_id).to eq expected_group_id
            expect(intake.zendesk_instance).to eq EitcZendeskInstance
          end
        end
      end

      it_behaves_like :source_group_matching, "uwkc", "360009173713"
      it_behaves_like :source_group_matching, "uwvp", "360009267673"
      it_behaves_like :source_group_matching, "uwccr", "360009708193"
      it_behaves_like :source_group_matching, "RefundDay-B", "360009704234"
      it_behaves_like :source_group_matching, "branchesfl", "360009704234"
      it_behaves_like :source_group_matching, "RefundDay-H", "360009415854"
      it_behaves_like :source_group_matching, "hispanicunity", "360009415854"
      it_behaves_like :source_group_matching, "uwfm", "360009415834"
      it_behaves_like :source_group_matching, "RefundDay-C", "360009704354"
      it_behaves_like :source_group_matching, "catalyst", "360009704354"

      context "when there is a source parameter that does not match an organization" do
        let(:source) { "propel" }
        let(:state) { "ne" }

        before do
          intake.assign_vita_partner!
        end

        it "uses the state to route" do
          expect(intake.reload.vita_partner.name).to eq "Tax Help Colorado (Piton Foundation)"
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end

      context "when source param is for an organization in an otherwise UWTSA state" do
        let(:source) { "fc" }
        let(:state) { "ny" }

        before do
          intake.assign_vita_partner!
        end

        it "assigns to the correct group and the correct instance" do
          expect(intake.reload.vita_partner.name).to eq "Foundation Communities"
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end
    end

    context "with state routing" do
      shared_examples :state_level_routing do |state_criteria, partner_name|
        context "given a state" do
          let(:state) { state_criteria } # might not be necessary?
          let(:partner) { VitaPartner.find_by!(name: partner_name) }

          before do
            intake.assign_vita_partner!
          end

          it "assigns to the correct group and the correct instance" do
            expect(intake.reload.vita_partner_group_id).to eq partner.zendesk_group_id
            expect(intake.zendesk_instance_domain).to eq partner.zendesk_instance_domain
          end
        end
      end

      it_behaves_like :state_level_routing, "CO", "Tax Help Colorado (Piton Foundation)", "eitc"
      it_behaves_like :state_level_routing, "CA", "[United Way California] Online Intake", "eitc"
      it_behaves_like :state_level_routing, "WA", "United Way of King County", "eitc"
      it_behaves_like :state_level_routing, "PA", "Campaign for Working Families", "eitc"
      it_behaves_like :state_level_routing, "NV", "Nevada Free Taxes Coalition", "eitc"
      it_behaves_like :state_level_routing, "TX", "Foundation Communities", "eitc"
      it_behaves_like :state_level_routing, "AZ", "United Way of Tucson and Southern Arizona", "eitc"
      it_behaves_like :state_level_routing, "VA", "United Way of Greater Richmond and Petersburg", "eitc"
      it_behaves_like :state_level_routing, "FL", "Tax Help Colorado (Piton Foundation)", "eitc"
      it_behaves_like :state_level_routing, "MD", "CASH Campaign of MD", "eitc"
      it_behaves_like :state_level_routing, "NY", "Urban Upbound (NY)", "eitc"
      it_behaves_like :state_level_routing, "RI", "Urban Upbound (NY)", "eitc"
      it_behaves_like :state_level_routing, "CT", "Urban Upbound (NY)", "eitc"
      it_behaves_like :state_level_routing, "DE", "Urban Upbound (NY)", "eitc"
      it_behaves_like :state_level_routing, "VT", "Urban Upbound (NY)", "eitc"
      it_behaves_like :state_level_routing, "ME", "Urban Upbound (NY)", "eitc"
      it_behaves_like :state_level_routing, "TN", "United Way of Greater Nashville", "eitc"
      it_behaves_like :state_level_routing, "GA", "United Way of Greater Nashville", "eitc"
      it_behaves_like :state_level_routing, "AL", "United Way of Central Alabama", "eitc"
      it_behaves_like :state_level_routing, "MA", "[MA/BTH] Online Intake (w/Boston Tax Help)", "eitc"
    end

    context "with overflow routing" do
      shared_examples "overflow routing" do |state_criteria|
        context "given a state" do
          let(:state) { state_criteria }
          let(:overflow_partners) { VitaPartner.where(accepts_overflow: true) }
          let(:overflow_partner_group_ids) { overflow_partners.map(&:zendesk_group_id) }
          let(:overflow_partner_instance_domains) { overflow_partners.map(&:zendesk_instance_domain) }

          before do
            intake.assign_vita_partner!
          end

          it "assigns to the correct group and the correct instance" do
            expect(overflow_partner_group_ids).to include intake.reload.vita_partner_group_id
            expect(overflow_partner_instance_domains).to include intake.zendesk_instance_domain
          end
        end
      end

      it_behaves_like "overflow routing", "XX"
      it_behaves_like "overflow routing", "AR"
      it_behaves_like "overflow routing", "MS"
      it_behaves_like "overflow routing", "SC"
    end
  end

  describe "#assign_vita_partner!" do
    let!(:vita_partner) { create :vita_partner, name: "test_partner", zendesk_group_id: partner_group_id }
    let(:partner_group_id) { "123456789" }

    # previously: a spec to ensure bad data stayed bad?

    context "for an intake without a zendesk group id" do
      let(:source_parameter) { SourceParameter.all.sample }
      let(:source_partner) { source_parameter.vita_partner }
      let(:intake_source) { source_parameter.code }
      let(:state) { 'CO' }
      let(:state_partner) { State.find(state).vita_partners.first }
      let(:overflow_partners) { VitaPartner.where(accepts_overflow: true) }
      let(:intake) { create :intake }

      context "with a valid source parameter" do
        let(:intake) { create :intake, source: intake_source }

        it "assigns the partner matching the source parameter" do
          intake.assign_vita_partner!
          expect(intake.vita_partner).to eq(source_partner)
        end
      end

      context "with an invalid source parameter (and valid state)" do
        let(:intake) { create :intake, source: 'noooooooooooooo', state_of_residence: state }

        it "assigns the partner matching the state" do
          intake.assign_vita_partner!
          expect(intake.vita_partner).to eq(state_partner)
        end
      end

      context "with no source and a nonsense state" do
        let(:intake) { create :intake, state: 'DESPAIR' }
        it 'assigns the partner to an overflow partner' do
          intake.assign_vita_partner!
          expect(overflow_partners.map(&:zendesk_group_id)).to include(intake.vita_partner.zendesk_group_id)
        end
      end
    end

    context "for an intake that is already assigned to the Uwtsa instance" do
      let(:intake) { create :intake, zendesk_instance_domain: UwtsaZendeskInstance::DOMAIN }

      it "doesn't assign a vita partner" do
        intake.assign_vita_partner!
        expect(intake.vita_partner).to be_nil
      end
    end

    context 'captures assignment information' do
      let(:state) { 'XX' }
      let(:zendesk_group_id) { '123456789101112' }
      let(:source_parameter) { 'a-source-parameter' }
      let(:vita_partner) do
        partner = create :vita_partner, zendesk_group_id: zendesk_group_id, accepts_overflow: true
        partner.states.create(abbreviation: state, name: 'doesn\'t matter')
        partner.source_parameters.create(code: source_parameter)
        partner
      end
      let(:intake) { create :intake }

      before do
        intake.assign_vita_partner!
      end

      it 'captures the routing timestamp' do
        expect(intake.routed_at).to be_within(2.seconds).of(Time.now)
      end

      context 'when routing by state' do
        let(:intake) { create :intake, state_of_residence: state }

        it "captures the routing method and target" do
          expect(intake.vita_partner_group_id).to eq(zendesk_group_id)
          expect(intake.routing_criteria).to eq("state")
          expect(intake.routing_value).to eq(state)
        end
      end

      context 'when routing by source parameter' do
        let(:intake) { create :intake, source: source_parameter }

        it "captures the routing method and target" do
          expect(intake.vita_partner_group_id).to eq(zendesk_group_id)
          expect(intake.routing_criteria).to eq("source_parameter")
          expect(intake.routing_value).to eq(source_parameter)
        end
      end

      context 'when routing by overflow' do
        let(:weird_state) { "ZZ" }
        let(:intake) { create :intake, state_of_residence: weird_state }

        it "captures the routing method and target" do
          overflow_group_ids = VitaPartner.where(accepts_overflow: true).map(&:zendesk_group_id)
          expect(overflow_group_ids).to include(intake.vita_partner_group_id)
          expect(intake.routing_criteria).to eq("overflow")
          expect(intake.routing_value).to eq(weird_state)
        end
      end
    end
  end

  describe "#might_encounter_delayed_service?" do
    let(:vita_partner) { create :vita_partner }
    let(:intake) { build :intake, vita_partner: vita_partner }

    before do
      allow(vita_partner).to receive(:has_capacity_for?).with(intake).and_return(true)
    end

    it "returns true if the partner does not have capacity for this intake" do
      expect(intake.might_encounter_delayed_service?).to eq false
      expect(vita_partner).to have_received(:has_capacity_for?).with(intake)
    end
  end

  describe "#contact_info_filtered_by_preferences" do
    let(:intake) do
      build :intake,
            sms_phone_number: "14158161286",
            email_address: "supermane@fantastic.horse",
            email_notification_opt_in: email,
            sms_notification_opt_in: sms
    end

    context "when they want all notifications" do
      let(:email){ "yes" }
      let(:sms){ "yes" }

      it "returns email and sms_phone_number in a hash" do
        expected_result = {
          email: "supermane@fantastic.horse",
          sms_phone_number: "+14158161286",
        }
        expect(intake.contact_info_filtered_by_preferences).to eq expected_result
      end
    end

    context "when they want sms only" do
      let(:email){ "no" }
      let(:sms){ "yes" }

      it "returns sms_phone_number in a hash" do
        expected_result = {
          sms_phone_number: "+14158161286",
        }
        expect(intake.contact_info_filtered_by_preferences).to eq expected_result

      end
    end

    context "when they want email only" do
      let(:email){ "yes" }
      let(:sms){ "no" }

      it "returns email in a hash" do
        expected_result = {
          email: "supermane@fantastic.horse",
        }
        expect(intake.contact_info_filtered_by_preferences).to eq expected_result
      end
    end

    context "when they don't want any notifications" do
      let(:email){ "no" }
      let(:sms){ "no" }

      it "returns an empty hash" do
        expect(intake.contact_info_filtered_by_preferences).to eq({})
      end
    end

    context "when the intake has a different phone_number and sms_phone_number" do
      let(:intake) do
        build :intake,
              sms_phone_number: "14159997777",
              phone_number: "14158161286",
              email_address: "supermane@fantastic.horse",
              email_notification_opt_in: "no",
              sms_notification_opt_in: "yes"
      end

      it "uses the sms_phone_number" do
        expected_result = {
          sms_phone_number: "+14159997777",
        }

        expect(intake.contact_info_filtered_by_preferences).to eq expected_result
      end
    end
  end

  describe "#age_end_of_tax_year" do
    let(:intake) { build :intake, primary_birth_date: Date.new(1990, 4, 21) }

    it "returns their age at the end of 2019" do
      expect(intake.age_end_of_tax_year).to eq 29
    end

    context "when birth_date is nil" do
      let(:intake) { build :intake, primary_birth_date: nil }

      it "returns nil and does not error" do
        expect(intake.age_end_of_tax_year).to be_nil
      end
    end
  end

  describe "#include_bank_details?" do
    let(:refund_method) {nil}
    let(:pay_from_bank) {nil}
    let(:intake) { create :intake, refund_payment_method: refund_method, balance_pay_from_bank: pay_from_bank }
    context "with an intake that wants their refund by direct deposit" do
      let(:refund_method) { "direct_deposit"}
      let(:pay_from_bank) {"no"}

      it "returns true" do
        expect(intake.include_bank_details?).to eq(true)
      end
    end

    context "with an intake that has not answered how they want their refund" do
      let(:refund_method) { "unfilled"}

      context "when they want to pay by bank account" do
        let(:pay_from_bank) {"yes"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq true
        end
      end

      context "when the have not answered whether they want to pay by bank account" do
        let(:pay_from_bank) {"unfilled"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq false
        end
      end

      context "when they do not want to pay by bank account" do
        let(:pay_from_bank) {"no"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq false
        end
      end
    end

    context "with an intake that wants their refund by check" do
      let(:refund_method) { "check"}

      context "when they want to pay by bank account" do
        let(:pay_from_bank) {"yes"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq true
        end
      end

      context "when the have not answered whether they want to pay by bank account" do
        let(:pay_from_bank) {"unfilled"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq false
        end
      end

      context "when they do not want to pay by bank account" do
        let(:pay_from_bank) {"no"}

        it "returns false" do
          expect(intake.include_bank_details?).to eq false
        end
      end
    end
  end

  describe "#current_ticket_status" do
    let!(:intake) {create :intake}
    let!(:old_status) {create :ticket_status, intake: intake, created_at: 3.days.ago}
    let!(:new_status) {create :ticket_status, intake: intake, created_at: 1.days.ago}

    it "returns the ticket status with the most recent created_at" do
      expect(intake.current_ticket_status).to eq new_status
    end
  end

  describe "#triaged_from_stimulus?" do
    let(:stimulus_triage) { create(:stimulus_triage) }
    let(:intake) { create(:intake) }

    context "when a stimulus triage is present" do
      before do
        intake.update_attribute(:triage_source, stimulus_triage)
      end

      it { expect(intake.triaged_from_stimulus?).to be_truthy }
    end

    context "when no stimulus triage is present" do
      it { expect(intake.triaged_from_stimulus?).to be_falsey }
    end
  end

  describe "#document_types_definitely_needed" do
    let(:intake) { create(:intake, bought_health_insurance: "yes") }

    it "returns list of must have documents" do
      expect(intake.document_types_definitely_needed).to eq ["ID", "Selfie", "SSN or ITIN", "1095-A"]
    end

    context "with already uploaded documents" do
      let!(:document) { create :document, intake: intake, document_type: "Selfie" }

      it "doesn't include already uploaded documents" do
        expect(intake.document_types_definitely_needed).to eq ["ID", "SSN or ITIN", "1095-A"]
      end
    end
  end

  describe "#document_types_possibly_needed" do
    let(:intake) { create(:intake, had_wages: "yes") }

    it "returns list of might have documents" do
      expect(intake.document_types_possibly_needed).to eq ["Employment"]
    end

    context "with already uploaded documents" do
      let!(:document) { create :document, intake: intake, document_type: "Employment" }

      it "doesn't include already uploaded documents" do
        expect(intake.document_types_possibly_needed).to eq []
      end
    end
  end
end
