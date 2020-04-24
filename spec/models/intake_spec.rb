# == Schema Information
#
# Table name: intakes
#
#  id                                                   :bigint           not null, primary key
#  additional_info                                      :string
#  adopted_child                                        :integer          default("unfilled"), not null
#  anonymous                                            :boolean          default(FALSE), not null
#  balance_pay_from_bank                                :integer          default("unfilled"), not null
#  bought_energy_efficient_items                        :integer
#  bought_health_insurance                              :integer          default("unfilled"), not null
#  city                                                 :string
#  completed_intake_sent_to_zendesk                     :boolean
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
#  encrypted_primary_last_four_ssn                      :string
#  encrypted_primary_last_four_ssn_iv                   :string
#  encrypted_spouse_last_four_ssn                       :string
#  encrypted_spouse_last_four_ssn_iv                    :string
#  ever_married                                         :integer          default("unfilled"), not null
#  feeling_about_taxes                                  :integer          default("unfilled"), not null
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
#  visitor_id                                           :string
#  zendesk_group_id                                     :string
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

    context "with a couple filing jointly" do
      let!(:primary) { create :user, intake: intake }
      let!(:spouse) { create :spouse_user, intake: intake }

      it "returns the first non-spouse user" do
        expect(intake.primary_user).to eq primary
      end
    end

    context "with one user" do
      let!(:primary) { create :user, intake: intake }

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

  describe "#mixpanel_data" do
    let(:intake) do
      build(
        :intake,
        had_disability: "no",
        spouse_had_disability: "yes",
        source: "beep",
        referrer: "http://boop.horse/mane",
        filing_joint: "no",
        had_wages: "yes",
        state: "ca",
        zip_code: "94609",
        intake_ticket_id: 9876,
        needs_help_2019: "yes",
        needs_help_2018: "no",
        needs_help_2017: "yes",
        needs_help_2016: "unfilled",
        primary_birth_date: Date.new(1993, 3, 12),
        spouse_birth_date: Date.new(1992, 5, 3),
      )
    end
    let!(:dependent_one) { create :dependent, birth_date: Date.new(2017, 4, 21), intake: intake}
    let!(:dependent_two) { create :dependent, birth_date: Date.new(2005, 8, 11), intake: intake}

    it "returns the expected hash" do
      expect(intake.mixpanel_data).to eq({
        intake_source: "beep",
        intake_referrer: "http://boop.horse/mane",
        intake_referrer_domain: "boop.horse",
        primary_filer_age_at_end_of_tax_year: "26",
        spouse_age_at_end_of_tax_year: "27",
        primary_filer_disabled: "no",
        spouse_disabled: "yes",
        had_dependents: "yes",
        number_of_dependents: "2",
        had_dependents_under_6: "yes",
        filing_joint: "no",
        had_earned_income: "yes",
        state: "ca",
        zip_code: "94609",
        needs_help_2019: "yes",
        needs_help_2018: "no",
        needs_help_2017: "yes",
        needs_help_2016: "unfilled",
        needs_help_backtaxes: "yes",
      })
    end

    context "when the intake is anonymous" do
      let(:anonymous_intake) {create :anonymous_intake, intake_ticket_id: 9876}

      it "returns the data for the original intake" do
        expect(anonymous_intake.mixpanel_data).to eq(intake.mixpanel_data)
      end
    end

    context "with no backtax help needed" do
      let(:intake) do
        build(
          :intake,
          needs_help_2019: "yes",
          needs_help_2018: "no",
          needs_help_2017: "no",
          needs_help_2016: "no"
        )
      end

      it "sends needs_help_backtaxes = no" do
        expect(intake.mixpanel_data).to include(needs_help_backtaxes: "no")
      end
    end
  end

  describe "#filing_years" do
    let(:intake) { create :intake, **filing_years }
    let(:filing_years) { {} }

    context "with unfilled filing years" do
      it "returns nil" do
        expect(intake.filing_years).to eq([])
      end
    end

    context "with a couple filing years selected" do
      let(:filing_years) do
        {
          needs_help_2019: "yes",
          needs_help_2018: "no",
          needs_help_2017: "yes",
          needs_help_2016: "unfilled",
        }
      end

      it "returns them as an array" do
        expect(intake.filing_years).to eq(["2019", "2017"])
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
    let(:intake) { build :intake, state_of_residence: state, source: source }

    context "when there is a source parameter" do
      context "when there is a source parameter that does not match an organization" do
        let(:source) { "propel" }
        let(:state) { "ne" }

        it "uses the state to route" do
          expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC
          expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end

      context "when source param starts with a organization's source parameter" do
        let(:source) { "uwkc-something" }
        let(:state) { "ne" }

        it "matches the correct group id" do
          expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
          expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end

      context "when source param is for an organization in an otherwise UWTSA state" do
        let(:source) { "uwco" }
        let(:state) { "oh" }

        it "matches the correct group and the correct instance" do
          expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_CENTRAL_OHIO
          expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_CENTRAL_OHIO
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end

      context "source matches an organization" do
        let(:source) { "uwkc" }
        let(:state) { "ne" }

        it "assigns to the UWKC group" do
          expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
          expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end

      context "source matches a key but is weirdly cased" do
        let(:source) { "UwVp" }
        let(:state) { "ne" }

        it "assigns to the UWVP group" do
          expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_VIRGINIA
          expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_VIRGINIA
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end
    end

    context "with Tax Help Colorado state" do
      let(:state) { "co" }

      it "assigns to the shared Tax Help Colorado / UWBA online intake group" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with United Way Bay Area states" do
      let(:state) { "ca" }

      it "assigns to the Online Intake - California group" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UWBA
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UWBA
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with a GWISR state" do
      let(:state) { "ga" }
      it "assigns to the Goodwill online intake" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_GWISR
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_GWISR
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with Washington state" do
      let(:state) { "wa" }
      it "assigns to United Way King County" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with Pennsylvania" do
      let(:state) { "pa" }
      it "assigns to Campaign for Working Families" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_WORKING_FAMILIES
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_WORKING_FAMILIES
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with Ohio" do
      let(:state) { "oh" }
      it "assigns to UW Central Ohio" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_CENTRAL_OHIO
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_CENTRAL_OHIO
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with New Jersey" do
      let(:state) { "nj" }
      it "assigns to Campaign for Working Families" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_WORKING_FAMILIES
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_WORKING_FAMILIES
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with South Carolina" do
      let(:state) { "sc" }
      it "assigns to Impact America - South Carolina" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_IA_SC
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_IA_SC
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with Tennessee" do
      let(:state) { "tn" }
      it "assigns to Impact America - Alabama" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_IA_AL
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_IA_AL
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with Nevada" do
      let(:state) { "nv" }
      it "assigns to Nevada Free Tax Coalition" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_NV_FTC
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_NV_FTC
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with Texas" do
      let(:state) { "tx" }
      it "assigns to Foundation Communities" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_FC
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_FC
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with Arizona" do
      let(:state) { "az" }

      it "assigns to the UW Tucson group" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_TSA
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_TSA
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with any other state" do
      let(:state) { "ny" }

      it "assigns to the UW Tucson instance" do
        expect(intake.get_or_create_zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_TSA
        expect(intake.reload.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_TSA
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end
  end

  describe "#contact_info_filtered_by_preferences" do
    let(:intake) do
      build :intake,
            phone_number: "14158161286",
            email_address: "supermane@fantastic.horse",
            email_notification_opt_in: email,
            sms_notification_opt_in: sms
    end

    context "when they want all notifications" do
      let(:email){ "yes" }
      let(:sms){ "yes" }

      it "returns email and phone_number in a hash" do
        expected_result = {
          email: "supermane@fantastic.horse",
          phone_number: "+14158161286",
        }
        expect(intake.contact_info_filtered_by_preferences).to eq expected_result
      end
    end

    context "when they want sms only" do
      let(:email){ "no" }
      let(:sms){ "yes" }

      it "returns phone_number in a hash" do
        expected_result = {
          phone_number: "+14158161286",
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
end
