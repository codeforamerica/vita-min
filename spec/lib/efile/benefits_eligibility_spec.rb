require "rails_helper"

describe Efile::BenefitsEligibility do
  let(:client) { create :client_with_ctc_intake_and_return }
  let(:intake) { client.intake }
  before do
    allow_any_instance_of(TaxReturn).to receive(:rrc_eligible_filer_count).and_return 1
    intake.dependents.destroy_all
    create :qualifying_child, intake: intake, birth_date: Date.new(TaxReturn.current_tax_year - 3, 01, 01)
    create :qualifying_child, intake: intake, birth_date: Date.new(TaxReturn.current_tax_year - 12, 01, 01)
    create :qualifying_child, intake: intake, permanently_totally_disabled: "yes", birth_date: Date.new(TaxReturn.current_tax_year - 40, 01, 01)
    create :qualifying_relative, intake: intake
  end

  describe "#eip1_amount" do
    context "tax year is 2020" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2020
      end

      it "calculates amount" do
        # 2 qualified children under age limit @ 500 ea
        # 1 qualified filer @ 1200 ea
        expect(Efile::BenefitsEligibility.new(tax_return: intake.tax_returns.last, dependents: intake.dependents).eip1_amount).to eq 2200
      end
    end

    context "tax year is 2021" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2021
      end

      it "calculates amount" do
        expect(Efile::BenefitsEligibility.new(tax_return: intake.tax_returns.last, dependents: intake.dependents).eip1_amount).to eq 0
      end
    end
  end
  
  describe "#eip2_amount" do
    context "tax year is 2020" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2020
      end

      it "calculates amount" do
        # 2 qualified children under age limit @ 600 ea
        # 1 qualified filer @ 600 ea
        expect(Efile::BenefitsEligibility.new(tax_return: intake.tax_returns.last, dependents: intake.dependents).eip2_amount).to eq 1800
      end
    end

    context "tax year is 2021" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2021
      end

      it "calculates amount" do
        expect(Efile::BenefitsEligibility.new(tax_return: intake.tax_returns.last, dependents: intake.dependents).eip2_amount).to eq 0
      end
    end
  end

  describe "#eip3_amount" do
    context "tax year is 2020" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2020
      end

      it "calculates amount" do
        # 3 qualified children under age limit @ 1400 ea
        # 1 qualified relative @ 1400 ea
        # 1 qualified filer @ 1400 ea
        expect(Efile::BenefitsEligibility.new(tax_return: intake.tax_returns.last, dependents: intake.dependents).eip3_amount).to eq 7000
      end
    end

    context "tax year is 2021" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2021
      end

      it "calculates amount" do
        # 3 qualified children under age limit @ 1400 ea
        # 1 qualified relative @ 1400 ea
        # 1 qualified filer @ 1400 ea
        expect(Efile::BenefitsEligibility.new(tax_return: intake.tax_returns.last, dependents: intake.dependents).eip3_amount).to eq 7000
      end
    end
  end

  describe "#ctc_amount" do
    context "tax year is 2020" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2020
      end

      it "calculates amount" do
        expect(Efile::BenefitsEligibility.new(tax_return: intake.tax_returns.last, dependents: intake.dependents).ctc_amount).to eq 0
      end
    end

    context "tax year is 2021" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2021
      end

      it "calculates amount" do
        # 1 qualified child under age 6 @ 3600 ea
        # 1 qualified child over 6 @ 3000 each
        expect(Efile::BenefitsEligibility.new(tax_return: intake.tax_returns.last, dependents: intake.dependents).ctc_amount).to eq 6600
      end
    end
  end
end