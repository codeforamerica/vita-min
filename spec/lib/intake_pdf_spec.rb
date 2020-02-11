require "rails_helper"

RSpec.describe IntakePdf do
  include PdfSpecHelper

  let(:intake_pdf) { IntakePdf.new(intake) }

  describe "#output_file" do
    context "with an empty intake record" do
      let(:intake) { create :intake }

      it "returns a pdf with default fields and values" do
        output_file = intake_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
          "had_wages" => "",
          "job_count" => "",
          "had_tips" => "",
          "had_retirement_income" => "",
          "had_social_security_income" => "",
          "had_unemployment_income" => "",
          "had_disability_income" => "",
          "had_interest_income" => "",
          "had_asset_sale_income" => "",
          "reported_asset_sale_loss" => "",
          "received_alimony" => "",
          "had_rental_income" => "",
          "had_farm_income" => "",
          "had_gambling_income" => "",
          "had_local_tax_refund" => "",
          "had_self_employment_income" => "",
          "reported_self_employment_loss" => "",
          "had_other_income" => "",
          "other_income_types" => "",
          "paid_mortgage_interest" => "",
          "paid_local_tax"  => "",
          "paid_medical_expenses" => "",
          "paid_charitable_contributions" => "",
          "paid_student_loan_interest" => "",
          "paid_dependent_care" => "",
          "paid_retirement_contributions" => "",
          "paid_school_supplies" => "",
          "paid_alimony" => "",
          "had_student_in_family" => "",
          "sold_a_home" => "",
          "had_hsa" => "",
          "bought_health_insurance" => "",
          "received_homebuyer_credit" => "",
          "had_debt_forgiven" => "",
          "had_disaster_loss" => "",
          "adopted_child" => "",
          "had_tax_credit_disallowed" => "",
          "received_irs_letter" => "",
          "made_estimated_tax_payments" => "",
          "additional_info" => "",
        })
      end
    end

    context "with a complete intake record" do
      let(:intake) do
        create(
          :intake,
          had_wages: "yes",
          had_tips: "yes",
          had_retirement_income: "yes",
          had_social_security_income: "yes",
          had_unemployment_income: "yes",
          had_disability_income: "no",
          had_interest_income: "yes",
          had_asset_sale_income: "yes",
          reported_asset_sale_loss: "yes",
          received_alimony: "yes",
          had_rental_income: "yes",
          had_farm_income: "no",
          had_gambling_income: "yes",
          had_local_tax_refund: "yes",
          had_self_employment_income: "yes",
          reported_self_employment_loss: "yes",
          had_other_income: "yes",
          other_income_types: "garden gnoming",
          paid_mortgage_interest: "no",
          paid_local_tax: "yes",
          paid_medical_expenses: "yes",
          paid_charitable_contributions: "yes",
          paid_student_loan_interest: "yes",
          paid_dependent_care: "no",
          paid_retirement_contributions: "yes",
          paid_school_supplies: "yes",
          paid_alimony: "yes",
          had_student_in_family: "no",
          sold_a_home: "no",
          had_hsa: "no",
          bought_health_insurance: "yes",
          received_homebuyer_credit: "yes",
          had_debt_forgiven: "yes",
          had_disaster_loss: "yes",
          adopted_child: "no",
          had_tax_credit_disallowed: "yes",
          received_irs_letter: "no",
          made_estimated_tax_payments: "yes",
          additional_info: "if there is another gnome living in my garden but only i have an income, does that make me head of household?"
        )
      end

      it "returns a filled out pdf" do
        output_file = intake_pdf.output_file
        result = filled_in_values(output_file.path)
        expect(result).to eq({
          "had_wages" => "Yes",
          "job_count" => "",
          "had_tips" => "Yes",
          "had_retirement_income" => "Yes",
          "had_social_security_income" => "Yes",
          "had_unemployment_income" => "Yes",
          "had_disability_income" => "",
          "had_interest_income" => "Yes",
          "had_asset_sale_income" => "Yes",
          "reported_asset_sale_loss" => "Yes",
          "received_alimony" => "Yes",
          "had_rental_income" => "Yes",
          "had_farm_income" => "",
          "had_gambling_income" => "Yes",
          "had_local_tax_refund" => "Yes",
          "had_self_employment_income" => "Yes",
          "reported_self_employment_loss" => "Yes",
          "had_other_income" => "Yes",
          "other_income_types" => "garden gnoming",
          "paid_mortgage_interest" => "",
          "paid_local_tax"  => "Yes",
          "paid_medical_expenses" => "Yes",
          "paid_charitable_contributions" => "Yes",
          "paid_student_loan_interest" => "Yes",
          "paid_dependent_care" => "",
          "paid_retirement_contributions" => "Yes",
          "paid_school_supplies" => "Yes",
          "paid_alimony" => "Yes",
          "had_student_in_family" => "",
          "sold_a_home" => "",
          "had_hsa" => "",
          "bought_health_insurance" => "Yes",
          "received_homebuyer_credit" => "Yes",
          "had_debt_forgiven" => "Yes",
          "had_disaster_loss" => "Yes",
          "adopted_child" => "",
          "had_tax_credit_disallowed" => "Yes",
          "received_irs_letter" => "",
          "made_estimated_tax_payments" => "Yes",
          "additional_info" => "if there is another gnome living in my garden but only i have an income, does that make me head of household?",
        })
      end
    end
  end
end