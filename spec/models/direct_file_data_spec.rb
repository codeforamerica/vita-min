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
end
