require 'rails_helper'

describe DirectFileData do
  describe '#ny_public_employee_retirement_contributions' do
    let(:desc1) { '414H' }
    let(:desc2) { '414 (H)' }

    before do
      xml = File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
      doc = Nokogiri::XML(xml)
      # clone the single w2 so there are two of them
      doc.at('IRSW2').add_next_sibling(doc.at('IRSW2').to_s)
      doc.css('IRSW2')[1]['documentId'] = 'W20002'

      # update both w2s to have a box14 code in the list
      doc.css('IRSW2')[0].at('AllocatedTipsAmt').add_next_sibling(<<~XML)
        <OtherDeductionsBenefitsGrp>
          <Desc>#{desc1}</Desc>
          <Amt>123</Amt>
        </OtherDeductionsBenefitsGrp>
      XML
      doc.css('IRSW2')[1].at('AllocatedTipsAmt').add_next_sibling(<<~XML)
        <OtherDeductionsBenefitsGrp>
          <Desc>#{desc2}</Desc>
          <Amt>100</Amt>
        </OtherDeductionsBenefitsGrp>
      XML

      @direct_file_data = DirectFileData.new(doc.to_s)
    end

    it "sums up the box14 amounts for anything associated with public employee retirement" do
      expect(@direct_file_data.ny_public_employee_retirement_contributions).to eq(223)
    end

    context "when the desc provided is not an exact match (different casing)" do
      let(:desc1) { '414h' }

      it "still sums up the numbers" do
        expect(@direct_file_data.ny_public_employee_retirement_contributions).to eq(223)
      end
    end
  end

  describe '#fed_adjustments_claimed' do

    before do
      xml = File.read(Rails.root.join('app', 'controllers', 'state_file', 'questions', 'df_return_sample.xml'))
      @doc = Nokogiri::XML(xml)
    end

    context "when all known adjustment types are present" do
      before do
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "generates a hash with all known types" do
        expect(@direct_file_data.fed_adjustments_claimed[:fed_educator_expenses][:amount]).to eq(300)
        expect(@direct_file_data.fed_adjustments_claimed[:fed_student_loan_interest][:amount]).to eq(2500)

        expect(@direct_file_data.fed_total_adjustments).to eq(2800)
      end
    end

    context "when not all known adjustment types are present" do
      before do
        @doc.at("IRS1040Schedule1 EducatorExpensesAmt").remove
        @doc.at("IRS1040Schedule1 TotalAdjustmentsAmt").content = "2500"
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "generates a hash with only the types that were present" do
        expect(@direct_file_data.fed_adjustments_claimed).not_to have_key(:fed_educator_expenses)
        expect(@direct_file_data.fed_adjustments_claimed[:fed_student_loan_interest][:amount]).to eq(2500)

        expect(@direct_file_data.fed_total_adjustments).to eq(2500)
      end
    end

    context "when some adjustment types have an amount of 0" do
      before do
        @doc.at("IRS1040Schedule1 StudentLoanInterestDedAmt").content = "0"
        @doc.at("IRS1040Schedule1 TotalAdjustmentsAmt").content = "300"
        @direct_file_data = DirectFileData.new(@doc.to_s)
      end

      it "generates a hash with only the types that had positive values" do
        expect(@direct_file_data.fed_adjustments_claimed).not_to have_key(:fed_student_loan_interest)
        expect(@direct_file_data.fed_adjustments_claimed[:fed_educator_expenses][:amount]).to eq(300)

        expect(@direct_file_data.fed_total_adjustments).to eq(300)
      end
    end

  end
end
