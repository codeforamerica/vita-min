require 'rails_helper'

describe SubmissionBuilder::StateReturn do
  states_requiring_w2s = StateFile::StateInformationService.active_state_codes.excluding("nc", "id")
  states_requiring_w2s.each do |state_code|
    describe "#combined_w2s", required_schema: state_code do
      let(:builder_class) { StateFile::StateInformationService.submission_builder_class(state_code) }
      let(:intake) { create("state_file_#{state_code}_intake".to_sym, filing_status: filing_status) }
      let(:submission) { create(:efile_submission, data_source: intake) }
      let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
      let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }

      context "#{state_code}: when there are w2s present" do
        let(:filing_status) { 'single' }

        context "when the intake does not have any state_file_w2s" do
          it "copies all w2s from the direct file xml field" do
            xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)
            expect(xml.css('IRSW2').count).to eq intake.direct_file_data.w2s.length
          end
        end

        context "when the intake has state_file_w2s" do
          context "create, update, delete nodes" do
            let(:intake) { create "state_file_#{state_code}_intake".to_sym, :df_data_2_w2s }
            let!(:state_file_w2) {
              create(
                :state_file_w2,
                state_file_intake: intake,
                w2_index: 1,
                employer_state_id_num: "00123",
                local_income_tax_amount: "0",
                local_wages_and_tips_amount: "2000",
                locality_nm: intake.direct_file_data.w2s[0].LocalityNm,
                state_income_tax_amount: "700",
                state_wages_amount: "2000",
                )
            }
            before do
              xml = Nokogiri::XML(intake.raw_direct_file_data)
              xml.search("IRSW2").each_with_index do |w2, i|
                if i == 1
                  w2.at("StateWagesAmt").remove
                end
              end
              intake.update(raw_direct_file_data: xml.to_xml)
            end

            it "prioritises state_file_w2s over w2s from the direct file xml, correctly updates & creates & deletes nodes" do
              xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)

              # w2 at index 0 remains the same
              w2_from_xml = xml.css('IRSW2')[0]
              expect(w2_from_xml.at("EmployerStateIdNum").text).to eq intake.direct_file_data.w2s[0].node.at("W2StateLocalTaxGrp EmployerStateIdNum").text
              expect(w2_from_xml.at("LocalIncomeTaxAmt").text).to eq intake.direct_file_data.w2s[0].node.at("W2StateLocalTaxGrp LocalIncomeTaxAmt").text
              expect(w2_from_xml.at("LocalWagesAndTipsAmt").text).to eq intake.direct_file_data.w2s[0].node.at("W2StateLocalTaxGrp LocalWagesAndTipsAmt").text
              expect(w2_from_xml.at("LocalityNm").text).to eq intake.direct_file_data.w2s[0].node.at("W2StateLocalTaxGrp LocalityNm").text.upcase
              expect(w2_from_xml.at("StateIncomeTaxAmt").text).to eq intake.direct_file_data.w2s[0].node.at("W2StateLocalTaxGrp StateIncomeTaxAmt").text
              expect(w2_from_xml.at("StateWagesAmt").text).to eq intake.direct_file_data.w2s[0].node.at("W2StateLocalTaxGrp StateWagesAmt").text

              # w2 at index 1 is filled in with info from client
              w2_from_db = xml.css('IRSW2')[1]
              expect(w2_from_db.at("EmployerStateIdNum").text).to eq state_file_w2.employer_state_id_num
              expect(w2_from_db.at("LocalIncomeTaxAmt")).to be_nil
              expect(w2_from_db.at("LocalWagesAndTipsAmt").text).to eq state_file_w2.local_wages_and_tips_amount.round.to_s
              expect(w2_from_db.at("LocalityNm").text).to eq state_file_w2.locality_nm
              expect(w2_from_db.at("StateIncomeTaxAmt").text).to eq state_file_w2.state_income_tax_amount.round.to_s
              expect(w2_from_db.at("StateWagesAmt").text).to eq state_file_w2.state_wages_amount.round.to_s
            end
          end

          context "updating multiple w2s" do
            let(:intake) { create "state_file_#{state_code}_intake".to_sym, :df_data_many_w2s }
            let!(:original_w2_count) { intake.direct_file_data.w2s.length }
            let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, w2_index: 0) }
            let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, w2_index: 1) }
            let!(:w2_3) { create(:state_file_w2, state_file_intake: intake, w2_index: 2) }
            let!(:w2_4) { create(:state_file_w2, state_file_intake: intake, w2_index: 3) }

            it "updates the correct tags" do
              generated_document = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml, &:noblanks)

              expect(generated_document.css('IRSW2').count).to eq original_w2_count
              (0..3).each do |i|
                expect(generated_document.css('IRSW2')[i].at("EmployerStateIdNum").text).to eq send("w2_#{i+1}").employer_state_id_num
                expect(generated_document.css('IRSW2')[i].at("LocalIncomeTaxAmt").text).to eq send("w2_#{i+1}").local_income_tax_amount.round.to_s
                expect(generated_document.css('IRSW2')[i].at("LocalWagesAndTipsAmt").text).to eq send("w2_#{i+1}").local_wages_and_tips_amount.round.to_s
                expect(generated_document.css('IRSW2')[i].at("LocalityNm").text).to eq send("w2_#{i+1}").locality_nm
                expect(generated_document.css('IRSW2')[i].at("StateIncomeTaxAmt").text).to eq send("w2_#{i+1}").state_income_tax_amount.round.to_s
                expect(generated_document.css('IRSW2')[i].at("StateWagesAmt").text).to eq send("w2_#{i+1}").state_wages_amount.round.to_s
              end
            end
          end
        end
      end
    end
  end

  states_requiring_1099gs = StateFile::StateInformationService.active_state_codes.excluding("nj")
  states_requiring_1099gs.each do |state_code|
    describe "#form1099gs", required_schema: state_code do
      context "#{state_code}: when there are 1099gs present" do
        let(:builder_class) { StateFile::StateInformationService.submission_builder_class(state_code) }
        let(:intake) { create("state_file_#{state_code}_intake".to_sym) }
        let(:submission) { create(:efile_submission, data_source: intake) }
        let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
        let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
        let!(:form1099g_1) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 100) }
        let!(:form1099g_2) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 200) }

        it "builds all 1099gs from intake" do
          xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)

          expect(xml.css("State1099G").count).to eq 2
        end
      end
    end
  end
end
