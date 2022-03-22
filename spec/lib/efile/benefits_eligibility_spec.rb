require "rails_helper"

describe Efile::BenefitsEligibility do
  let(:subject) { Efile::BenefitsEligibility.new(tax_return: intake.tax_returns.last, dependents: intake.dependents) }

  let(:client) { create :client_with_ctc_intake_and_return }
  let(:intake) { client.intake }
  before do
    allow_any_instance_of(Efile::BenefitsEligibility).to receive(:rrc_eligible_filer_count).and_return 1
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
        expect(subject.eip1_amount).to eq 2200
      end
    end

    context "tax year is 2021" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2021
      end

      it "calculates amount" do
        expect(subject.eip1_amount).to eq 0
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
        expect(subject.eip2_amount).to eq 1800
      end
    end

    context "tax year is 2021" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2021
      end

      it "calculates amount" do
        expect(subject.eip2_amount).to eq 0
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
        expect(subject.eip3_amount).to eq 7000
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
        expect(subject.eip3_amount).to eq 7000
      end
    end
  end

  describe "#ctc_amount" do
    context "tax year is 2020" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2020
      end

      it "calculates amount" do
        expect(subject.ctc_amount).to eq 0
      end
    end

    context "tax year is 2021" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2021
      end

      it "calculates amount" do
        # 1 qualified child under age 6 @ 3600 ea
        # 1 qualified child over 6 @ 3000 each
        expect(subject.ctc_amount).to eq 6600
      end
    end
  end

  describe "#outstanding_recovery_rebate_credit" do
    let(:client) { create :client_with_ctc_intake_and_return, intake: create(:intake, eip1_amount_received: eip1_amount_received, eip2_amount_received: eip2_amount_received, eip3_amount_received: eip3_amount_received) }
    let(:eip1_amount_received) { 0 }
    let(:eip2_amount_received) { 0 }
    let(:eip3_amount_received) { 0 }

    context "tax year is 2020" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2020
      end

      context "when received credit is higher than expected for eip 1, and has some outstanding for eip2" do
        let(:eip1_amount_received) { 4000 }
        let(:eip2_amount_received) { 1000 }
        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip1_amount).and_return(2400)
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip2_amount).and_return(1200)
        end

        it "qualifies for outstanding eip2 amount" do
          expect(subject.outstanding_recovery_rebate_credit).to eq 200
        end
      end

      context "when received credit is higher than expected for eip2, but has some outstanding for eip1" do
        let(:eip1_amount_received) { 1200 }
        let(:eip2_amount_received) { 1300 }
        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip1_amount).and_return(2400)
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip2_amount).and_return(1200)
        end

        it "qualifies for outstanding eip1 amount" do
          expect(subject.outstanding_recovery_rebate_credit).to eq 1200
        end
      end

      context "when there is outstanding credit for eip1 and eip2" do
        let(:eip1_amount_received) { 2300 }
        let(:eip2_amount_received) { 1100 }
        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip1_amount).and_return(2400)
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip2_amount).and_return(1200)
        end

        it "qualifies for outstanding eip1+eip2 amount" do
          expect(subject.outstanding_recovery_rebate_credit).to eq 200
        end
      end

      context "when there is no outstanding credit for either" do
        let(:eip1_amount_received) { 2400 }
        let(:eip2_amount_received) { 1200 }

        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip1_amount).and_return 2400
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip2_amount).and_return 1200
        end

        it "has a 0 amount" do
          expect(subject.outstanding_recovery_rebate_credit).to eq 0
        end
      end
    end

    context "tax year is 2021" do
      before do
        allow_any_instance_of(TaxReturn).to receive(:year).and_return 2021
      end

      context "when there is outstanding credit for eip3" do
        let(:eip3_amount_received) { 2000 }
        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount).and_return(2400)
        end

        it "qualifies for outstanding eip3 amount" do
          expect(subject.outstanding_recovery_rebate_credit).to eq 400
        end
      end

      context "when there is no outstanding credit for eip3" do
        let(:eip3_amount_received) { 2400 }

        before do
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount).and_return 2400
        end

        it "has a 0 amount" do
          expect(subject.outstanding_recovery_rebate_credit).to eq 0
        end
      end
    end
  end

  describe "#rrc_eligible_filer_count" do
    before do
      allow_any_instance_of(Efile::BenefitsEligibility).to receive(:rrc_eligible_filer_count).and_call_original
    end

    context "when filing status is single" do
      let(:client) { create :client, :with_return, filing_status: :single, intake: create(:ctc_intake, primary_tin_type: tin_type) }
      let(:tin_type) { :itin }

      context "when the primary is using an ITIN" do
        it "filer_count is 0" do
          expect(subject.rrc_eligible_filer_count).to eq 0
        end
      end

      context "when the primary is using an SSN" do
        let(:tin_type) { :ssn }

        it "filer count is 1" do
          expect(subject.rrc_eligible_filer_count).to eq 1
        end
      end
    end

    context "when filing with a spouse" do
      let(:client) { create :client, :with_return, filing_status: :married_filing_jointly }
      let(:spouse_military) { "no" }
      let(:primary_military) { "no" }
      let(:primary_tin_type) { "itin" }
      let(:spouse_tin_type) { "itin" }
      let(:intake) do
        create :ctc_intake,
               client: client,
               spouse_active_armed_forces: spouse_military,
               primary_active_armed_forces: primary_military,
               spouse_tin_type: spouse_tin_type,
               primary_tin_type: primary_tin_type
      end

      context "when a spouse is part of the armed forces" do
        let(:spouse_military) { "yes" }

        it "has a filer count of 2" do
          expect(subject.rrc_eligible_filer_count).to eq 2
        end
      end

      context "when primary is part of the armed forces" do
        let(:primary_military) { "yes" }

        it "has a filer count of 2" do
          expect(subject.rrc_eligible_filer_count).to eq 2
        end
      end

      context "when primary is using an ssn and spouse is using ITIN" do
        let(:primary_tin_type) { "ssn" }

        it "has a filer count of one" do
          expect(subject.rrc_eligible_filer_count).to eq 1
        end
      end

      context "when primary is using an ITIN and spouse is using SSN" do
        let(:spouse_tin_type) { "ssn" }

        it "has a filer count of one" do
          expect(subject.rrc_eligible_filer_count).to eq 1
        end
      end

      context "when both are using ITIN" do
        it "has a filer count of 0" do
          expect(subject.rrc_eligible_filer_count).to eq 0
        end
      end
    end
  end
end