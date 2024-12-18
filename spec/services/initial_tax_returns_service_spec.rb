require "rails_helper"

describe InitialTaxReturnsService do
  describe "#create!" do

    before do
      allow(BaseService).to receive(:ensure_transaction).and_yield
    end

    subject { described_class.new(intake: intake) }

    context "when current and previous year are requested" do
      let(:intake) { create :intake, needs_help_current_year: "yes", needs_help_previous_year_1: "yes" }

      it "creates in-progress tax returns for the required years" do
        subject.create!
        expect(intake.tax_returns.pluck(:current_state).uniq).to eq ["intake_in_progress"]
        expect(intake.tax_returns.count).to eq 2
        expect(intake.tax_returns.pluck(:year)).to match_array([MultiTenantService.new(:gyr).current_tax_year, MultiTenantService.new(:gyr).current_tax_year - 1])
      end

    end

    context "when a tax return for a selected year already exists" do
      let!(:tax_return) { create :tax_return, :intake_in_progress, client: intake.client, year: MultiTenantService.new(:gyr).current_tax_year - 3 }
      let(:intake) { create :intake, needs_help_current_year: "yes", needs_help_previous_year_1: "yes", needs_help_previous_year_3: "yes" }

      before do
        allow(Rails.application.config).to receive(:gyr_current_tax_year).and_return(2023)
      end

      around do |example|
        Timecop.freeze(DateTime.parse("2024-04-14")) do
          example.run
        end
      end

      it "uses the existing tax return object and does not crash" do
        subject.create!

        expect(intake.tax_returns.count).to eq 3
        expect(intake.tax_returns.pluck(:year)).to match_array([MultiTenantService.new(:gyr).current_tax_year - 3, MultiTenantService.new(:gyr).current_tax_year - 1, MultiTenantService.new(:gyr).current_tax_year])
        expect(intake.tax_returns.find_by(year: MultiTenantService.new(:gyr).current_tax_year - 3)).to eq tax_return
      end
    end

    context "when a tax return had existed for a specific year but the needs_help_xxxx value is now false" do
      let!(:tax_return) { create :tax_return, :intake_in_progress, client: intake.client, year: MultiTenantService.new(:gyr).current_tax_year }
      let(:intake) { create :intake, needs_help_current_year: "no", needs_help_previous_year_1: "yes" }

      it "keeps the tax return associated" do
        expect {
          subject.create!
        }.to change { intake.tax_returns.pluck(:year).sort }.from([MultiTenantService.new(:gyr).current_tax_year]).to([MultiTenantService.new(:gyr).current_tax_year - 1, MultiTenantService.new(:gyr).current_tax_year])
      end
    end
  end
end
