require "rails_helper"

describe Ctc::SpouseFiledPriorTaxYearForm do
  let(:client) { create :client, tax_returns: [(build :ctc_tax_return, filing_status: nil)]}
  let!(:intake) { create :ctc_intake, client: client }
  let(:params) { { spouse_filed_prior_tax_year: filed_prior_year } }
  let(:filed_prior_year) { "filed_together" }

  context "validations" do
    context "when filing status is selected" do
      it "is valid" do
        expect(
          described_class.new(intake, params)
        ).to be_valid
      end
    end

    context "when spouse_filed_prior_tax_year is not filled in" do
      it "is not valid" do
        expect(
            described_class.new(intake, {})
        ).not_to be_valid
      end
    end

    context "when spouse_filed_prior_tax_year is not part of the expected value set" do
      let(:filed_prior_year) { "on_the_moon" }

      it "is not saved" do
        form = described_class.new(intake, params)
        expect { form.save }.to raise_error(ArgumentError, /'on_the_moon' is not a valid spouse_filed_prior_tax_year/)
      end
    end
  end

  context "save" do
    context "filed_together" do
      let(:filed_prior_year) { "filed_together" }

      context "primary was not a filed_non_filer" do
        before do
          intake.update(filed_prior_tax_year: :filed_full)
        end

        it "updates spouse_filed_prior_tax_year" do
          expect {
            described_class.new(intake, params).save
          }.to change(intake, :spouse_filed_prior_tax_year).from("unfilled").to("filed_together")
        end
      end

      context "primary was a filed_non_filer" do
        before do
          intake.update(filed_prior_tax_year: :filed_non_filer)
        end

        it "updates spouse filed prior year" do
          expect {
            described_class.new(intake, params).save
          }.to change(intake, :spouse_filed_prior_tax_year).from("unfilled").to("filed_together")
        end
      end
    end

    context "filed_full_separate" do
      let(:filed_prior_year) { "filed_full_separate" }
      it "updates spouse filed prior year, does not set agi" do
        expect {
          described_class.new(intake, params).save
        }.to change(intake, :spouse_filed_prior_tax_year).from("unfilled").to("filed_full_separate")
      end
    end

    context "did_not_file" do
      let(:filed_prior_year) { "did_not_file" }
      it "updates spouse filed prior year, does not set agi" do
        expect {
          described_class.new(intake, params).save
        }.to change(intake, :spouse_filed_prior_tax_year).from("unfilled").to("did_not_file")
      end
    end

    context "filed_non_filer_separate" do
      let(:filed_prior_year) { "filed_non_filer_separate" }
      it "updates spouse filed prior year" do
        expect {
          described_class.new(intake, params).save
        }.to change(intake, :spouse_filed_prior_tax_year).from("unfilled").to("filed_non_filer_separate")
      end
    end
  end
end
