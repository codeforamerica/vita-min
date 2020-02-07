# == Schema Information
#
# Table name: intakes
#
#  id                            :bigint           not null, primary key
#  additional_info               :string
#  adopted_child                 :integer          default("unfilled"), not null
#  bought_health_insurance       :integer          default("unfilled"), not null
#  city                          :string
#  divorced                      :integer          default("unfilled"), not null
#  divorced_year                 :string
#  filing_joint                  :integer          default("unfilled"), not null
#  had_asset_sale_income         :integer          default("unfilled"), not null
#  had_debt_forgiven             :integer          default("unfilled"), not null
#  had_disability_income         :integer          default("unfilled"), not null
#  had_disaster_loss             :integer          default("unfilled"), not null
#  had_farm_income               :integer          default("unfilled"), not null
#  had_gambling_income           :integer          default("unfilled"), not null
#  had_hsa                       :integer          default("unfilled"), not null
#  had_interest_income           :integer          default("unfilled"), not null
#  had_local_tax_refund          :integer          default("unfilled"), not null
#  had_other_income              :integer          default("unfilled"), not null
#  had_rental_income             :integer          default("unfilled"), not null
#  had_retirement_income         :integer          default("unfilled"), not null
#  had_self_employment_income    :integer          default("unfilled"), not null
#  had_social_security_income    :integer          default("unfilled"), not null
#  had_student_in_family         :integer          default("unfilled"), not null
#  had_tax_credit_disallowed     :integer          default("unfilled"), not null
#  had_tips                      :integer          default("unfilled"), not null
#  had_unemployment_income       :integer          default("unfilled"), not null
#  had_wages                     :integer          default("unfilled"), not null
#  job_count                     :integer
#  lived_with_spouse             :integer          default("unfilled"), not null
#  made_estimated_tax_payments   :integer          default("unfilled"), not null
#  married                       :integer          default("unfilled"), not null
#  married_all_year              :integer          default("unfilled"), not null
#  other_income_types            :string
#  paid_alimony                  :integer          default("unfilled"), not null
#  paid_charitable_contributions :integer          default("unfilled"), not null
#  paid_dependent_care           :integer          default("unfilled"), not null
#  paid_local_tax                :integer          default("unfilled"), not null
#  paid_medical_expenses         :integer          default("unfilled"), not null
#  paid_mortgage_interest        :integer          default("unfilled"), not null
#  paid_retirement_contributions :integer          default("unfilled"), not null
#  paid_school_supplies          :integer          default("unfilled"), not null
#  paid_student_loan_interest    :integer          default("unfilled"), not null
#  received_alimony              :integer          default("unfilled"), not null
#  received_homebuyer_credit     :integer          default("unfilled"), not null
#  received_irs_letter           :integer          default("unfilled"), not null
#  referrer                      :string
#  reported_asset_sale_loss      :integer          default("unfilled"), not null
#  reported_self_employment_loss :integer          default("unfilled"), not null
#  separated                     :integer          default("unfilled"), not null
#  separated_year                :string
#  sold_a_home                   :integer          default("unfilled"), not null
#  source                        :string
#  state                         :string
#  street_address                :string
#  widowed                       :integer          default("unfilled"), not null
#  widowed_year                  :string
#  zip_code                      :string
#  created_at                    :datetime
#  updated_at                    :datetime
#

require 'rails_helper'

describe Intake do
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
end
