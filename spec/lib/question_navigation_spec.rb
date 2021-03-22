require "rails_helper"

describe QuestionNavigation do
  context ".determine_current_step" do
    context "when before consent" do
      let(:intake) { create :intake }
      it "directs to the consent page" do
        expect(described_class.determine_current_step(intake)).to eq "/en/questions/consent"
      end
    end

    context "with all yes_no_questions completed but needs documents" do
      let(:intake) { create :intake, primary_consented_to_service_at: DateTime.current, completed_yes_no_questions_at: DateTime.current }
      before do
        allow(intake).to receive(:document_types_definitely_needed).and_return [DocumentTypes::Selfie]
      end

      it "directs to the documents overview page" do
        expect(described_class.determine_current_step(intake)).to eq "/en/documents/overview"
      end
    end

    context "with some yes/no questions completed" do
      context "answered up to life situations" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 was_full_time_student: "yes"
        }
        it "has next step as issued-identity-pin" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/issued-identity-pin"
        end
      end

      context "answered up to ever married with yes" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 was_full_time_student: "yes",
                 issued_identity_pin: "no",
                 ever_married: "yes"
        }
        it "has next step as married" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/married"
        end
      end

      context "answered up to ever married with no (takes into account skipped questions)" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 was_full_time_student: "yes",
                 issued_identity_pin: "no",
                 ever_married: "no"
        }
        it "has next step as had-dependents" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/had-dependents"
        end
      end

      context "answered up to dependent care" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 was_full_time_student: "yes",
                 issued_identity_pin: "no",
                 ever_married: "no",
                 had_dependents: "yes",
                 paid_dependent_care: "unfilled"
        }
        it "has next step as dependent-care" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/dependent-care"
        end
      end

      context "answered up to other states" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 was_full_time_student: "yes",
                 issued_identity_pin: "no",
                 ever_married: "no",
                 had_dependents: "no",
                 paid_dependent_care: "yes",
                 adopted_child: "no",
                 had_student_in_family: "no",
                 paid_student_loan_interest: "yes",
                 job_count: 2,
                 multiple_states: "unfilled"

        }
        it "has next step as other-states" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/other-states"
        end
      end

      context "answered up to had asset sale" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 was_full_time_student: "yes",
                 issued_identity_pin: "no",
                 ever_married: "no",
                 had_dependents: "no",
                 paid_dependent_care: "yes",
                 adopted_child: "no",
                 had_student_in_family: "no",
                 paid_student_loan_interest: "yes",
                 job_count: 2,
                 multiple_states: "yes",
                 had_wages: "yes",
                 had_self_employment_income: "no",
                 had_disability_income: "no",
                 had_interest_income: "unsure",
                 sold_assets: "yes",
                 had_asset_sale_income: "unfilled"
        }
        it "has next step as asset-sale-income" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/asset-sale-income"
        end
      end

      context "answered up to health insurance" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 was_full_time_student: "yes",
                 issued_identity_pin: "no",
                 ever_married: "no",
                 had_dependents: "no",
                 paid_dependent_care: "yes",
                 adopted_child: "no",
                 had_student_in_family: "no",
                 paid_student_loan_interest: "yes",
                 job_count: 2,
                 multiple_states: "yes",
                 had_wages: "yes",
                 had_self_employment_income: "no",
                 had_disability_income: "no",
                 had_interest_income: "unsure",
                 sold_assets: "no",
                 had_asset_sale_income: "no",
                 had_social_security_or_retirement: "no",
                 had_other_income: "no",
                 bought_health_insurance: "unfilled"
        }
        it "has next step as health-insurance" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/health-insurance"
        end
      end

      context "answered up to paid school supplies" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 was_full_time_student: "yes",
                 issued_identity_pin: "no",
                 ever_married: "no",
                 had_dependents: "no",
                 paid_dependent_care: "yes",
                 adopted_child: "no",
                 had_student_in_family: "no",
                 paid_student_loan_interest: "yes",
                 job_count: 2,
                 multiple_states: "yes",
                 had_wages: "yes",
                 had_self_employment_income: "no",
                 had_disability_income: "no",
                 had_interest_income: "unsure",
                 sold_assets: "no",
                 had_asset_sale_income: "no",
                 had_social_security_or_retirement: "no",
                 had_other_income: "no",
                 bought_health_insurance: "yes",
                 had_hsa: "no",
                 paid_medical_expenses: "no",
                 paid_charitable_contributions: "no",
                 had_gambling_income: "no",
                 paid_school_supplies: "unfilled"
        }
        it "has next step as health-insurance" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/school-supplies"
        end
      end

      context "answered up to disaster loss" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 was_full_time_student: "yes",
                 issued_identity_pin: "no",
                 ever_married: "no",
                 had_dependents: "no",
                 paid_dependent_care: "yes",
                 adopted_child: "no",
                 had_student_in_family: "no",
                 paid_student_loan_interest: "yes",
                 job_count: 2,
                 multiple_states: "yes",
                 had_wages: "yes",
                 had_self_employment_income: "no",
                 had_disability_income: "no",
                 had_interest_income: "unsure",
                 sold_assets: "no",
                 had_asset_sale_income: "no",
                 had_social_security_or_retirement: "no",
                 had_other_income: "no",
                 bought_health_insurance: "yes",
                 had_hsa: "no",
                 paid_medical_expenses: "no",
                 paid_charitable_contributions: "no",
                 had_gambling_income: "no",
                 paid_school_supplies: "yes",
                 paid_local_tax: "no",
                 had_local_tax_refund: "no",
                 sold_a_home: "no",
                 paid_mortgage_interest: "no",
                 received_homebuyer_credit: "no",
                 had_disaster_loss: "unfilled"
        }
        it "has next step as health-insurance" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/disaster-loss"
        end
      end

      context "answered up to additional info" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 was_full_time_student: "yes",
                 issued_identity_pin: "no",
                 ever_married: "no",
                 had_dependents: "no",
                 paid_dependent_care: "yes",
                 adopted_child: "no",
                 had_student_in_family: "no",
                 paid_student_loan_interest: "yes",
                 job_count: 2,
                 multiple_states: "yes",
                 had_wages: "yes",
                 had_self_employment_income: "no",
                 had_disability_income: "no",
                 had_interest_income: "unsure",
                 sold_assets: "no",
                 had_asset_sale_income: "no",
                 had_social_security_or_retirement: "no",
                 had_other_income: "no",
                 bought_health_insurance: "yes",
                 had_hsa: "no",
                 paid_medical_expenses: "no",
                 paid_charitable_contributions: "no",
                 had_gambling_income: "no",
                 paid_school_supplies: "yes",
                 paid_local_tax: "no",
                 had_local_tax_refund: "no",
                 sold_a_home: "no",
                 paid_mortgage_interest: "no",
                 received_homebuyer_credit: "no",
                 had_disaster_loss: "yes",
                 had_debt_forgiven: "yes",
                 received_irs_letter: "yes",
                 had_tax_credit_disallowed: "yes",
                 made_estimated_tax_payments: "yes",
                 reported_self_employment_loss: "yes",
                 bought_energy_efficient_items: "yes",
                 additional_info: nil
        }
        it "has next step as additional-info" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/additional-info"
        end
      end

    end

    context "with documents submitted but final questions to complete" do
      before do
        allow(intake).to receive(:document_types_definitely_needed).and_return []
      end

      context "without interview scheduling answered" do
        let(:intake) { create :intake, primary_consented_to_service_at: DateTime.current, completed_yes_no_questions_at: DateTime.current }
        it "sends you to interview scheduling" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/interview-scheduling"
        end
      end

      context "with interview scheduling answered" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 completed_yes_no_questions_at: DateTime.current,
                 interview_timing_preference: "anytime is fine with me",
                 refund_payment_method: "unfilled"
        }

        it "sends you to refund payment options" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/refund-payment"
        end
      end

      context "with refund payment method answered" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 completed_yes_no_questions_at: DateTime.current,
                 interview_timing_preference: "anytime is fine with me",
                 refund_payment_method: "direct_deposit"
        }

        it "sends you to refund payment options" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/savings-options"
        end
      end

      context "with up to mailing address answered" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 completed_yes_no_questions_at: DateTime.current,
                 interview_timing_preference: "anytime is fine with me",
                 refund_payment_method: "direct_deposit",
                 savings_purchase_bond: "yes",
                 balance_pay_from_bank: "no",
                 bank_name: "Bank of America",
                 street_address: "23627 Luna Lane"
        }

        it "sends you to refund payment options" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/demographic-questions"
        end
      end

      context "when demographic questions are not opted into" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 completed_yes_no_questions_at: DateTime.current,
                 interview_timing_preference: "anytime is fine with me",
                 refund_payment_method: "direct_deposit",
                 savings_purchase_bond: "yes",
                 balance_pay_from_bank: "no",
                 bank_name: "Bank of America",
                 street_address: "23627 Luna Lane",
                 demographic_questions_opt_in: "no"
        }

        it "sends you to refund payment options" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/final-info"
        end
      end

      context "when demographic questions are opted into" do
        let(:intake) {
          create :intake,
                 primary_consented_to_service_at: DateTime.current,
                 completed_yes_no_questions_at: DateTime.current,
                 interview_timing_preference: "anytime is fine with me",
                 refund_payment_method: "direct_deposit",
                 savings_purchase_bond: "yes",
                 balance_pay_from_bank: "no",
                 bank_name: "Bank of America",
                 street_address: "23627 Luna Lane",
                 demographic_questions_opt_in: "yes"
        }

        it "takes you through the demographic questions" do
          expect(described_class.determine_current_step(intake)).to eq "/en/questions/demographic-english-conversation"
        end

        context "when demographic questions are opted into" do
          let(:intake) {
            create :intake,
                   primary_consented_to_service_at: DateTime.current,
                   completed_yes_no_questions_at: DateTime.current,
                   interview_timing_preference: "anytime is fine with me",
                   refund_payment_method: "direct_deposit",
                   savings_purchase_bond: "yes",
                   balance_pay_from_bank: "no",
                   bank_name: "Bank of America",
                   street_address: "23627 Luna Lane",
                   demographic_questions_opt_in: "yes",
                   demographic_english_conversation: "not_well",
                   demographic_english_reading: "not_well",
                   demographic_disability: "no",
                   demographic_veteran: "yes",
                   demographic_primary_american_indian_alaska_native: "yes"
          }

          it "takes you through the demographic questions" do
            expect(described_class.determine_current_step(intake)).to eq "/en/questions/demographic-primary-ethnicity"
          end
        end

      end
    end
  end
end