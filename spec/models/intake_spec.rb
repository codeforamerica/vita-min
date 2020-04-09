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
#  sold_a_home                                          :integer          default("unfilled"), not null
#  source                                               :string
#  spouse_auth_token                                    :string
#  spouse_had_disability                                :integer          default("unfilled"), not null
#  spouse_issued_identity_pin                           :integer          default("unfilled"), not null
#  spouse_was_blind                                     :integer          default("unfilled"), not null
#  spouse_was_full_time_student                         :integer          default("unfilled"), not null
#  spouse_was_on_visa                                   :integer          default("unfilled"), not null
#  state                                                :string
#  street_address                                       :string
#  was_blind                                            :integer          default("unfilled"), not null
#  was_full_time_student                                :integer          default("unfilled"), not null
#  was_on_visa                                          :integer          default("unfilled"), not null
#  widowed                                              :integer          default("unfilled"), not null
#  widowed_year                                         :string
#  zip_code                                             :string
#  created_at                                           :datetime
#  updated_at                                           :datetime
#  intake_ticket_id                                     :bigint
#  intake_ticket_requester_id                           :bigint
#  visitor_id                                           :string
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

  describe "#additional_info_png" do
    let(:intake) { create :intake }

    before do
      allow_any_instance_of(AdditionalInfoPdf).to receive(:as_png).and_return("i am a png")
    end

    it "generates an additional info pdf for this intake" do
      result = intake.additional_info_png
      expect(result).to eq "i am a png"
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

  describe "#greeting_name" do
    let(:intake) { create :intake }
    let!(:primary_user) { create :user, first_name: "Porpoise", intake: intake}

    context "with a single filer" do
      it "returns the first name of the filer" do
        expect(intake.greeting_name).to eq "Porpoise"
      end
    end

    context "with a married couple filing jointly" do
      let!(:spouse_user) { create :user, first_name: "Porcupine", is_spouse: true, intake: intake }
      it "returns first name of primary and first name of spouse" do
        expect(intake.greeting_name).to eq "Porpoise and Porcupine"
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

  describe "#address_matches_primary_user_address?" do
    let(:first_address) do
      {
        street_address: "123 Main St.",
        city: "Oaktown",
        state: "CA",
        zip_code: "94609",
      }
    end

    let(:second_address) do
      {
        street_address: "321 Side St.",
        city: "Oakland",
        state: "CA",
        zip_code: "94609",
      }
    end

    let(:intake) { create :intake, **first_address }

    context "when the addresses match" do
      let!(:user) { create :user, intake: intake, **first_address, state: "ca" }

      it "returns true" do
        expect(intake.address_matches_primary_user_address?).to eq true
      end
    end

    context "when the addresses don't match" do
      let!(:user) { create :user, intake: intake, **second_address }

      it "returns false" do
        expect(intake.address_matches_primary_user_address?).to eq false
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
        create :intake, was_full_time_student: "yes", spouse_was_full_time_student: "yes"
      end
      before do
        create :user, intake: intake, first_name: "Henrietta", last_name: "Huckleberry"
        create :spouse_user, intake: intake, first_name: "Helga", last_name: "Huckleberry"
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
        create :intake, was_full_time_student: "no", spouse_was_full_time_student: "unfilled"
      end

      before do
        create :user, intake: intake, first_name: "Henrietta", last_name: "Huckleberry"
        create :spouse_user, intake: intake, first_name: "Helga", last_name: "Huckleberry"
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
        create :intake, was_full_time_student: "no", spouse_was_full_time_student: "no"
      end

      before do
        create :user, intake: intake, first_name: "Henrietta", last_name: "Huckleberry"
        create :spouse_user, intake: intake, first_name: "Helga", last_name: "Huckleberry"
        create :dependent, intake: intake, first_name: "Harriet", last_name: "Huckleberry", was_student: "no"
        create :dependent, intake: intake, first_name: "Henry", last_name: "Huckleberry", was_student: "no"
      end

      it "returns an empty array" do
        expect(intake.student_names).to eq([])
      end
    end

    context "when there is no spouse verified but the spouse was a student" do
      let(:intake) do
        create :intake, was_full_time_student: "yes", spouse_was_full_time_student: "yes"
      end

      before do
        create :user, intake: intake, first_name: "Henrietta", last_name: "Huckleberry"
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
        referrer: "boop",
        filing_joint: "no",
        had_wages: "yes",
        state: "ca",
        zip_code: "94609",
        needs_help_2019: "yes",
        needs_help_2018: "no",
        needs_help_2017: "yes",
        needs_help_2016: "unfilled",
      )
    end
    let!(:primary_user) { create :user, intake: intake, birth_date: "1993-03-12" }
    let!(:spouse_user) { create :user, is_spouse: true, intake: intake, birth_date: "1992-05-03" }
    let!(:dependent_one) { create :dependent, birth_date: Date.new(2017, 4, 21), intake: intake}
    let!(:dependent_two) { create :dependent, birth_date: Date.new(2005, 8, 11), intake: intake}
    before { allow(intake).to receive(:referrer_domain).and_return("blep") }

    it "returns the expected hash" do
      expect(intake.mixpanel_data).to eq({
        intake_source: "beep",
        intake_referrer: "boop",
        intake_referrer_domain: "blep",
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

  describe "Zendesk routing" do
    let(:source) { nil }
    let(:intake) { build :intake, state: state, source: source }

    context "when there is a source parameter" do
      context "when there is a source parameter that does not match an organization" do
        let(:source) { "propel" }
        let(:state) { "ne" }

        it "uses the state to route" do
          expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end

      context "when source param starts with a organization's source parameter" do
        let(:source) { "uwkc-something" }
        let(:state) { "ne" }

        it "matches the correct group id" do
          expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end

      context "when source param is for an organization in an otherwise UWTSA state" do
        let(:source) { "uwco" }
        let(:state) { "oh" }

        it "matches the correct group and the correct instance" do
          expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_CENTRAL_OHIO
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end

      context "source matches an organization" do
        let(:source) { "uwkc" }
        let(:state) { "ne" }

        it "assigns to the UWKC group" do
          expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end

      context "source matches a key but is weirdly cased" do
        let(:source) { "UwVp" }
        let(:state) { "ne" }

        it "assigns to the UWVP group" do
          expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_VIRGINIA
          expect(intake.zendesk_instance).to eq EitcZendeskInstance
        end
      end
    end

    context "with Tax Help Colorado state" do
      let(:state) { "co" }

      it "assigns to the shared Tax Help Colorado / UWBA online intake group" do
        expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_THC
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with United Way Bay Area states" do
      let(:state) { "ca" }

      it "assigns to the Online Intake - California group" do
        expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UWBA
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with a GWISR state" do
      let(:state) { "ga" }
      it "assigns to the Goodwill online intake" do
        expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_GWISR
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with Washington state" do
      let(:state) { "wa" }
      it "assigns to United Way King County" do
        expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_UW_KING_COUNTY
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with Pennsylvania" do
      let(:state) { "pa" }
      it "assigns to Campaign for Working Families" do
        expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_WORKING_FAMILIES
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with South Carolina" do
      let(:state) { "sc" }
      it "assigns to Impact America - South Carolina" do
        expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_IA_SC
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with Tennessee" do
      let(:state) { "tn" }
      it "assigns to Impact America - Alabama" do
        expect(intake.zendesk_group_id).to eq EitcZendeskInstance::ONLINE_INTAKE_IA_AL
        expect(intake.zendesk_instance).to eq EitcZendeskInstance
      end
    end

    context "with any other state" do
      let(:state) { "ny" }
      it "assigns to the UW Tucson intake" do
        expect(intake.zendesk_group_id).to be_nil
        expect(intake.zendesk_instance).to eq UwtsaZendeskInstance
      end
    end
  end
end
