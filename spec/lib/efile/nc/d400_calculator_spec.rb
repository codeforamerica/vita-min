require 'rails_helper'

describe Efile::Nc::D400Calculator do
  let(:intake) { create(:state_file_nc_intake) }
  let(:instance) do
    described_class.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end

  describe "Line 10b: Child Deduction" do
    [
      [["single", "married_filing_separately"], [
        [20_000, 6000],
        [30_000, 5000],
        [40_000, 4000],
        [50_000, 3000],
        [60_000, 2000],
        [70_000, 1000],
        [70_001, 0],
      ]],
      [["head_of_household"], [
        [30_000, 6000],
        [45_000, 5000],
        [60_000, 4000],
        [75_000, 3000],
        [90_000, 2000],
        [105_000, 1000],
        [105_001, 0]
      ]],
      [["married_filing_jointly", "qualifying_widow"], [
        [40_000, 6000],
        [60_000, 5000],
        [80_000, 4000],
        [100_000, 3000],
        [120_000, 2000],
        [140_000, 1000],
        [140_001, 0]
      ]]
    ].each do |filing_statuses, agis_to_deductions|
      filing_statuses.each do |filing_status|
        context "#{filing_status}" do
          let(:intake) { create(:state_file_nc_intake, filing_status: filing_status, raw_direct_file_data: StateFile::DirectFileApiResponseSampleService.new.read_xml("nc_shiloh_hoh")) }
          let(:calculator_instance) { described_class.new(year: MultiTenantService.statefile.current_tax_year, intake: intake) }

          agis_to_deductions.each do |fagi, deduction_amt_for_two_children|
            it "returns the value corresponding to #{fagi} FAGI multiplied by number of QCs" do
              intake.direct_file_data.fed_agi = fagi
              intake.direct_file_data.qualifying_children_under_age_ssn_count = 2

              calculator_instance.calculate
              expect(calculator_instance.lines[:NCD400_LINE_10B].value).to eq(deduction_amt_for_two_children)
            end
          end
        end
      end
    end
  end

  describe "Line 11: Standard Deduction" do
    [
      ["head_of_household", 19125],
      ["married_filing_jointly", 25500],
      ["married_filing_separately", 12750],
      ["qualifying_widow", 25500],
      ["single", 12750],
    ].each do |filing_status, deduction_amount|
      context "#{filing_status} filer" do
        let(:intake) { create :state_file_nc_intake, filing_status: filing_status }

        it "returns the correct value" do
          instance.calculate
          expect(instance.lines[:NCD400_LINE_11].value).to eq(deduction_amount)
        end
      end
    end
  end

  describe "Line 12a: NCAGIAddition" do
    it "sums lines 10b and 11 (9 is blank)" do
      allow(instance).to receive(:calculate_line_10b).and_return 10
      allow(instance).to receive(:calculate_line_11).and_return 10

      instance.calculate
      expect(instance.lines[:NCD400_LINE_12A].value).to eq 20
    end
  end

  describe "Line 12b: NCAGISubtraction" do
    it "subtracts line 12a from line 8 (which is just fed agi)" do
      allow(instance).to receive(:calculate_line_12a).and_return 10
      allow_any_instance_of(DirectFileData).to receive(:fed_agi).and_return 100

      instance.calculate
      expect(instance.lines[:NCD400_LINE_12B].value).to eq 90
    end
  end

  describe "Line 15: North Carolina Income Tax" do
    context "value (line 14 (which = line 12b) * 0.045 rounded to the nearest dollar) is positive" do
      it "returns the value rounded up" do
        allow(instance).to receive(:calculate_line_12b).and_return 100

        instance.calculate
        expect(instance.lines[:NCD400_LINE_15].value).to eq 5
      end

      it "returns the value rounded down" do
        allow(instance).to receive(:calculate_line_12b).and_return 50

        instance.calculate
        expect(instance.lines[:NCD400_LINE_15].value).to eq 2
      end
    end

    context "value (line 14 (which = line 12b) * 0.045 rounded to the nearest dollar) is negative" do
      it "returns zero" do
        allow(instance).to receive(:calculate_line_12b).and_return(-100)

        instance.calculate
        expect(instance.lines[:NCD400_LINE_15].value).to eq 0
      end
    end
  end

  describe "Line 18: Consumer Use Tax" do
    context "they have untaxed out of state purchases and selected automated calculation" do
      let(:intake) { create(:state_file_nc_intake, untaxed_out_of_state_purchases: "yes", sales_use_tax_calculation_method: "automated") }

      context "nc taxable income is negative" do
        it "returns 1" do
          allow(instance).to receive(:calculate_line_14).and_return -1_000
          instance.calculate

          expect(instance.lines[:NCD400_LINE_18].value).to eq 1
        end
      end

      context "nc taxable income is 2,100" do
        it "returns 1" do
          allow(instance).to receive(:calculate_line_14).and_return 2_100
          instance.calculate

          expect(instance.lines[:NCD400_LINE_18].value).to eq 1
        end
      end

      context "nc taxable income is 2,200" do
        it "returns 2" do
          allow(instance).to receive(:calculate_line_14).and_return 2_200
          instance.calculate

          expect(instance.lines[:NCD400_LINE_18].value).to eq 2
        end
      end

      context "nc taxable income is 33,500" do
        it "returns 23" do
          allow(instance).to receive(:calculate_line_14).and_return 33_500
          instance.calculate

          expect(instance.lines[:NCD400_LINE_18].value).to eq 23
        end
      end

      context "nc taxable income is 47,000" do
        it "returns 23 (nc taxable income * .000675)" do
          allow(instance).to receive(:calculate_line_14).and_return 47_000
          instance.calculate

          expect(instance.lines[:NCD400_LINE_18].value).to eq 32
        end
      end
    end

    context "they have untaxed out of state purchases and selected manual calculation" do
      let(:intake) { create(:state_file_nc_intake, untaxed_out_of_state_purchases: "yes", sales_use_tax_calculation_method: "manual", sales_use_tax: "3") }

      context "nc taxable income is 2,100" do
        it "returns their entered sales use tax" do
          allow(instance).to receive(:calculate_line_14).and_return 2_100
          instance.calculate

          expect(instance.lines[:NCD400_LINE_18].value).to eq 3
        end
      end
    end
  end

  describe "Line 19" do
    it "adds line 17 and 18" do
      allow(instance).to receive(:calculate_line_17).and_return 102
      allow(instance).to receive(:calculate_line_18).and_return 206

      instance.calculate
      expect(instance.lines[:NCD400_LINE_19].value).to eq 308
    end
  end

  describe "Line 20a: North Carolina Income Tax Withheld" do
    let(:intake) { create(:state_file_nc_intake) }
    let(:primary_ssn_from_fixture) { intake.primary.ssn }
    let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, state_income_tax_amount: 100, employee_ssn: primary_ssn_from_fixture) }
    let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, state_income_tax_amount: 200, employee_ssn: other_ssn) }
    let!(:state_file1099_g) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 50, recipient: 'primary') }
    let!(:state_file1099_g_2) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 39.5, recipient: 'spouse') }

    context "only one w2 and 1099G matches primary ssn" do
      let(:other_ssn) { "222334444" }

      it "sums StateIncomeTaxAmt (W2) for only the matching ssn" do
        instance.calculate
        expect(instance.lines[:NCD400_LINE_20A].value).to eq(150)
      end
    end

    context "more than one w2 matches primary ssn and one 1099G" do
      let(:other_ssn) { primary_ssn_from_fixture }

      it "sums StateIncomeTaxAmt (W2) and state_income_tax_withheld_amount (1099G) for all matching ssn's" do
        instance.calculate
        expect(instance.lines[:NCD400_LINE_20A].value).to eq(350)
      end
    end
  end

  describe "Line 20b: North Carolina Income Tax Withheld: Spouse's tax withheld" do
    let(:intake) { create(:state_file_nc_intake) }
    let(:spouse_ssn_from_fixture) { intake.spouse.ssn }
    let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, state_income_tax_amount: 100, employee_ssn: spouse_ssn_from_fixture) }
    let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, state_income_tax_amount: 100, employee_ssn: other_ssn) }
    let!(:state_file1099_g) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 50, recipient: 'primary') }
    let!(:state_file1099_g_2) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 39.5, recipient: 'spouse') }

    context "only one w2 and 1099G matches spouse ssn" do
      let(:other_ssn) { "222334444" }

      it "sums StateIncomeTaxAmt for only the matching ssn" do
        instance.calculate
        expect(instance.lines[:NCD400_LINE_20B].value).to eq(140)
      end
    end

    context "more than one w2 and one 1099G matches spouse ssn" do
      let(:other_ssn) { spouse_ssn_from_fixture }

      it "sums StateIncomeTaxAmt for all matching ssn's" do
        instance.calculate
        expect(instance.lines[:NCD400_LINE_20B].value).to eq(240)
      end
    end
  end

  describe "Line 23: Add Lines 20a through 22" do
    it "adds the other lines" do
      allow(instance).to receive(:calculate_line_20a).and_return 5
      allow(instance).to receive(:calculate_line_20b).and_return 5

      instance.calculate
      expect(instance.lines[:NCD400_LINE_23].value).to eq(10)
    end
  end

  describe "Line 26a: Tax Due" do
    context "they owe money" do
      it "returns line 19 - line 25" do
        allow(instance).to receive(:calculate_line_19).and_return 200
        allow(instance).to receive(:calculate_line_25).and_return 100
        
        instance.calculate
        expect(instance.lines[:NCD400_LINE_26A].value).to eq 100
      end
    end

    context "they have a refund" do
      it "returns nil" do
        allow(instance).to receive(:calculate_line_19).and_return 100
        allow(instance).to receive(:calculate_line_25).and_return 250

        instance.calculate
        expect(instance.lines[:NCD400_LINE_26A].value).to eq nil
      end
    end
  end

  describe "Line 27: Amount Due" do
    context "line 26a is positive" do
      it "they owe money" do
        allow(instance).to receive(:calculate_line_26a).and_return 100

        instance.calculate
        expect(instance.lines[:NCD400_LINE_27].value).to eq 100
      end
    end

    context "line 26a is nil" do
      it "returns 0" do
        allow(instance).to receive(:calculate_line_26a).and_return nil

        instance.calculate
        expect(instance.lines[:NCD400_LINE_27].value).to eq 0
      end
    end
  end

  describe "Line 28: Overpayment" do
    context "they owe money" do
      it "returns line 19 - line 25" do
        allow(instance).to receive(:calculate_line_19).and_return 200
        allow(instance).to receive(:calculate_line_25).and_return 100

        instance.calculate
        expect(instance.lines[:NCD400_LINE_28].value).to eq nil
      end
    end

    context "they have a refund" do
      it "returns nil" do
        allow(instance).to receive(:calculate_line_19).and_return 100
        allow(instance).to receive(:calculate_line_25).and_return 250

        instance.calculate
        expect(instance.lines[:NCD400_LINE_28].value).to eq 150
      end
    end
  end

  describe "Line 34: Amount To Be Refunded" do
    it "equals line 28" do
      allow(instance).to receive(:calculate_line_28).and_return 250

      instance.calculate
      expect(instance.lines[:NCD400_LINE_34].value).to eq 250
    end
  end
end