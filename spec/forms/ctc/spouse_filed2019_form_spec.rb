require "rails_helper"

describe Ctc::SpouseFiled2019Form do
  let(:client) { create :client, tax_returns: [(create :tax_return, filing_status: nil )]}
  let!(:intake) { create :ctc_intake, client: client }
  let(:params) { { spouse_filed_2019: filed_2019 } }
  let(:filed_2019) { "filed_full_joint" }

  context "validations" do
    context "when filing status is selected" do
      it "is valid" do
        expect(
            described_class.new(intake, params)
        ).to be_valid
      end
    end

    context "when spouse_filed_2019 is not filled in" do
      it "is not valid" do
        expect(
            described_class.new(intake, {})
        ).not_to be_valid
      end
    end

    context "when spouse_filed_2019 is not in the set" do
      let(:filed_2019) { "on_the_moon" }
      it "is not valid" do
        expect {
          described_class.new(intake, params).save
        }.to raise_error ArgumentError
      end
    end
  end

  context "save" do
    context "filed_full_joint" do
      let(:filed_2019) { "filed_full_joint" }
      it "updates spouse filed 2019, does not set agi" do
        expect {
          described_class.new(intake, params).save
        }.to change(intake, :spouse_filed_2019).from("unfilled").to("filed_full_joint")
         .and not_change(intake, :spouse_prior_year_agi_amount)
      end
    end

    context "filed_non_filer_joint" do
      let(:filed_2019) { "filed_non_filer_joint" }
      it "updates spouse filed 2019, sets AGI to 1" do
        expect {
          described_class.new(intake, params).save
        }.to change(intake, :spouse_filed_2019).from("unfilled").to("filed_non_filer_joint")
         .and change(intake, :spouse_prior_year_agi_amount).from(nil).to(1)
      end
    end

    context "filed_full_separate" do
      let(:filed_2019) { "filed_full_separate" }
      it "updates spouse filed 2019, sets AGI to 1" do
        expect {
          described_class.new(intake, params).save
        }.to change(intake, :spouse_filed_2019).from("unfilled").to("filed_full_separate")
        .and not_change(intake, :spouse_prior_year_agi_amount)
      end
    end

    context "did_not_file" do
      let(:filed_2019) { "did_not_file" }
      it "updates spouse filed 2019, does not set agi" do
        expect {
          described_class.new(intake, params).save
        }.to change(intake, :spouse_filed_2019).from("unfilled").to("did_not_file")
        .and not_change(intake, :spouse_prior_year_agi_amount)
      end
    end

    context "filed_non_filer_separate" do
      let(:filed_2019) { "filed_non_filer_separate" }
      it "updates spouse filed 2019, does not set agi" do
        expect {
          described_class.new(intake, params).save
        }.to change(intake, :spouse_filed_2019).from("unfilled").to("filed_non_filer_separate")
         .and change(intake, :spouse_prior_year_agi_amount).from(nil).to(1)
      end
    end
  end
end