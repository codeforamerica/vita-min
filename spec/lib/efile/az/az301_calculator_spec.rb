require 'rails_helper'

describe Efile::Az::Az301Calculator do
  let(:intake) { create(:state_file_az_intake, :with_az321_contributions, :with_az322_contributions) }
  let(:az140_calculator) do
    Efile::Az::Az140Calculator.new(
      year: MultiTenantService.statefile.current_tax_year,
      intake: intake
    )
  end
  let(:instance) { az140_calculator.instance_variable_get(:@az301) }

  before do
    intake.charitable_cash_amount = 50
    intake.charitable_noncash_amount = 50
    intake.charitable_contributions = 'yes'
    intake.direct_file_data.filing_status = 2 # married_filing_jointly
    intake.reload
    az140_calculator.calculate
  end

  describe 'AZ301 calculations' do
    it "enters the credit for Contributions to Qualifying Charitable Organizations" do
      expect(instance.lines[:AZ301_LINE_6a].value).to eq(938)
      expect(instance.lines[:AZ301_LINE_6c].value).to eq(938)
    end

    it "enters the credit for Contributions Made or Fees Paid to Public Schools" do
      expect(instance.lines[:AZ301_LINE_7a].value).to eq(400)
      expect(instance.lines[:AZ301_LINE_7c].value).to eq(400)
    end

    it "calculates total available nonrefundable tax credits" do
      expect(instance.lines[:AZ301_LINE_26].value).to eq(1338)
    end

    it "calculates AZ301 part 2 values" do
      expect(instance.lines[:AZ301_LINE_27].value).to eq(2077) # Line 46 from AZ140
      expect(instance.lines[:AZ301_LINE_32].value).to eq(2077)
      expect(instance.lines[:AZ301_LINE_33].value).to eq(0) # Line 50 from AZ140
      expect(instance.lines[:AZ301_LINE_34].value).to eq(2077) # Difference from line 27 and 33
    end

    it "calculates Nonrefundable Tax Credits Used This Taxable Year correctly" do
      expect(instance.lines[:AZ301_LINE_40].value).to eq(938)
      expect(instance.lines[:AZ301_LINE_41].value).to eq(400)
      expect(instance.lines[:AZ301_LINE_60].value).to eq(1338)
      expect(instance.lines[:AZ301_LINE_62].value).to eq(1338)
    end

    context "line 40" do
      context "with 6c greater than line 34 value" do
        before do
          allow(instance).to receive(:calculate_line_6c).and_return 1_000
          allow(instance).to receive(:calculate_line_34).and_return 500
        end

        it "line 40 value is equal to line 34 value" do
          instance.calculate
          expect(instance.lines[:AZ301_LINE_40].value).to eq(500)
        end
      end

      context "with line 6c less than line 34" do
        before do
          allow(instance).to receive(:calculate_line_6c).and_return 500
          allow(instance).to receive(:calculate_line_34).and_return 1000
        end

        it "line 40 value is equal to line 6c value" do
          instance.calculate
          expect(instance.lines[:AZ301_LINE_40].value).to eq(500)
        end
      end

      context "with line 6c blank" do
        before do
          allow(instance).to receive(:calculate_line_6c).and_return nil
          allow(instance).to receive(:calculate_line_34).and_return 1000
        end

        it "line 40 value is equal to zero" do
          instance.calculate
          expect(instance.lines[:AZ301_LINE_40].value).to eq(0)
        end
      end

      context "with line 34 blank" do
        before do
          allow(instance).to receive(:calculate_line_6c).and_return 10
          allow(instance).to receive(:calculate_line_34).and_return nil
        end

        it "line 40 value is equal to zero" do
          instance.calculate
          expect(instance.lines[:AZ301_LINE_40].value).to eq(0)
        end
      end
    end

    context "line 41" do
      context "line 34 greater than line 40" do
        before do
          allow(instance).to receive(:calculate_line_34).and_return 120
          allow(instance).to receive(:calculate_line_40).and_return 100
        end

        context "line 7c greater than subtraction" do
          before do
            allow(instance).to receive(:calculate_line_7c).and_return 30
          end

          it "should return the subtraction amount" do
            instance.calculate
            expect(instance.lines[:AZ301_LINE_41].value).to eq(20)
          end
        end

        context "line 7c less than subtraction" do
          before do
            allow(instance).to receive(:calculate_line_7c).and_return 10
          end

          it "should return the 7c amount" do
            instance.calculate
            expect(instance.lines[:AZ301_LINE_41].value).to eq(10)
          end
        end
      end

      context "line 34 less than line 40" do
        before do
          allow(instance).to receive(:calculate_line_34).and_return 90
          allow(instance).to receive(:calculate_line_40).and_return 100
        end

        context "line 7c greater than subtraction" do
          before do
            allow(instance).to receive(:calculate_line_7c).and_return 10
          end

          it "returns 0" do
            instance.calculate
            expect(instance.lines[:AZ301_LINE_41].value).to eq(0)
          end
        end

        context "line 7c equal to subtraction" do
          before do
            allow(instance).to receive(:calculate_line_7c).and_return 0
          end

          it "returns 0" do
            instance.calculate
            expect(instance.lines[:AZ301_LINE_41].value).to eq(0)
          end
        end
      end

      context "line 34 equal to line 40" do
        before do
          allow(instance).to receive(:calculate_line_34).and_return 90
          allow(instance).to receive(:calculate_line_40).and_return 90
        end

        context "line 7c greater than subtraction" do
          before do
            allow(instance).to receive(:calculate_line_7c).and_return 100
          end

          it "returns 0" do
            instance.calculate
            expect(instance.lines[:AZ301_LINE_41].value).to eq(0)
          end
        end

        context "line 7c equal to subtraction which is 0" do
          before do
            allow(instance).to receive(:calculate_line_7c).and_return 0
          end

          it "returns 0" do
            instance.calculate
            expect(instance.lines[:AZ301_LINE_41].value).to eq(0)
          end
        end
      end
    end
  end
end
