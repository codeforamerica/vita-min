require "rails_helper"

describe InitialTaxReturnsService do
  describe "#create!" do
    let(:intake) { create :intake, needs_help_2021: "yes", needs_help_2020: "yes" }

    before do
      allow(BaseService).to receive(:ensure_transaction).and_yield
    end

    subject { described_class.new(intake: intake) }

    it "creates in-progress tax returns for the required years" do
      subject.create!
      expect(intake.tax_returns.pluck(:current_state).uniq).to eq ["intake_in_progress"]
      expect(intake.tax_returns.count).to eq 2
      expect(intake.tax_returns.pluck(:year)).to match_array([2021, 2020])
    end

    context "when a tax return for a selected year already exists" do
      let!(:tax_return) { create :tax_return, :intake_in_progress, client: intake.client, year: 2019 }

      before do
        intake.update(needs_help_2019: "yes")
      end

      it "uses the existing tax return object and does not crash" do
        subject.create!

        expect(intake.tax_returns.count).to eq 3
        expect(intake.tax_returns.pluck(:year)).to match_array([2019, 2020, 2021])
        expect(intake.tax_returns.find_by(year: 2019)).to eq tax_return
      end
    end

    context "when a tax return had existed for a specific year but the needs_help_xxxx value is now false" do
      let!(:tax_return) { create :tax_return, :intake_in_progress, client: intake.client, year: 2021 }

      before do
        intake.update(needs_help_2021: "no")
      end

      it "keeps the tax return associated" do
        expect {
          subject.create!
        }.to change { intake.tax_returns.pluck(:year).sort }.from([2021]).to([2020, 2021])
      end
    end
  end
end
