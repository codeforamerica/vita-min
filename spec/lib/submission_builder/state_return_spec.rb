require 'rails_helper'

spec_vars = {
  default: {
    w2_node_name: "IRSW2",
    employer_state_id_num_name: "EmployerStateIdNum",
    locality_name: "LocalityNm"
  },
  nj: {
    w2_node_name: "NJW2",
    employer_state_id_num_name: "EmployersStateIdNumber",
    locality_name: "NameOfLocality"
  }
}

describe SubmissionBuilder::StateReturn do
  states_requiring_w2s = StateFile::StateInformationService.active_state_codes.excluding("id", "nc")
  states_requiring_w2s.each do |state_code|
    describe "#combined_w2s", required_schema: state_code do
      let(:builder_class) { StateFile::StateInformationService.submission_builder_class(state_code) }
      let(:intake) { create("state_file_#{state_code}_intake".to_sym) }
      let(:submission) { create(:efile_submission, data_source: intake) }
      let(:vars) { spec_vars[state_code.to_sym] || spec_vars[:default] }
      before do
        intake.synchronize_df_w2s_to_database
      end

      context "#{state_code}: when there are w2s present" do
        context "when the intake has state_file_w2s" do
          context "create, update, delete nodes" do
            let(:intake) { create "state_file_#{state_code}_intake".to_sym, :df_data_2_w2s }

            it "copies the state and local tags from the state_file_w2s table into the state return xml" do
              xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)

              intake.state_file_w2s.each_with_index do |state_file_w2, index|
                w2_xml = xml.css(vars[:w2_node_name])[index]
                expect(w2_xml.at(vars[:employer_state_id_num_name]).text).to eq state_file_w2.employer_state_id_num
                expect(w2_xml.at("LocalIncomeTaxAmt").text).to eq state_file_w2.local_income_tax_amount.round.to_s
                expect(w2_xml.at("LocalWagesAndTipsAmt").text).to eq state_file_w2.local_wages_and_tips_amount.round.to_s
                expect(w2_xml.at(vars[:locality_name]).text).to eq state_file_w2.locality_nm if state_file_w2.locality_nm.present?
                expect(w2_xml.at("StateIncomeTaxAmt").text).to eq state_file_w2.state_income_tax_amount.round.to_s
                expect(w2_xml.at("StateWagesAmt").text).to eq state_file_w2.state_wages_amount.round.to_s
              end
            end
          end
        end
      end
    end
  end

  describe "Maryland W2 Box 14 STPICKUP handling" do
    let(:builder_class) { SubmissionBuilder::Ty2024::States::Md::MdReturnXml }
    let(:intake) { create(:state_file_md_intake, :df_data_2_w2s, filing_status: 'single') }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:w2_node_name) { "IRSW2" }

    context "when W2 has box14_stpickup" do
      let!(:state_file_w2) do
        create(
          :state_file_w2,
          state_file_intake: intake,
          w2_index: 0,
          box14_stpickup: 750.50,
        )
      end
      before do
        xml = Nokogiri::XML(intake.raw_direct_file_data)
        intake.update(raw_direct_file_data: xml.to_xml)
      end

      it "includes STPICKUP in OtherDeductionsBenefitsGrp with rounded amount" do
        xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)
        w2_node = xml.css(w2_node_name).first
        expect(xml.css("OtherDeductionsBenefitsGrp Desc").map(&:text)).to include("STPICKUP")
        expect(w2_node.css("OtherDeductionsBenefitsGrp Desc")[1]&.text).to eq "STPICKUP"
        expect(w2_node.css("OtherDeductionsBenefitsGrp Amt")[1]&.text).to eq "751"
      end

      it "preserves existing OtherDeductionsBenefitsGrp entries" do
        xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)
        w2_node = xml.css(w2_node_name).first

        expect(w2_node.css("OtherDeductionsBenefitsGrp Desc")[0]&.text).to eq "414HSUB"
        expect(w2_node.css("OtherDeductionsBenefitsGrp Amt")[0]&.text).to eq "250"
      end
    end

    context "when W2 has zero box14_stpickup" do
      let!(:state_file_w2) do
        create(
          :state_file_w2,
          state_file_intake: intake,
          w2_index: 0,
          box14_stpickup: "0",
          employer_state_id_num: "12345",
          state_wages_amount: "50000"
        )
      end

      it "does not include STPICKUP in XML" do
        xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)
        expect(xml.css("OtherDeductionsBenefitsGrp Desc").map(&:text)).to include("STPICKUP")
      end
    end

    context "when W2 has nil box14_stpickup" do
      let!(:state_file_w2) do
        create(
          :state_file_w2,
          state_file_intake: intake,
          w2_index: 0,
          box14_stpickup: nil,
          employer_state_id_num: "12345",
          state_wages_amount: "50000"
        )
      end

      it "does not include STPICKUP in XML" do
        xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)
        expect(xml.css("OtherDeductionsBenefitsGrp Desc").map(&:text)).not_to include("STPICKUP")
      end
    end
  end

  states_requiring_1099gs = StateFile::StateInformationService.active_state_codes.excluding("id", "md", "nj")
  states_requiring_1099gs.each do |state_code|
    describe "#form1099gs", required_schema: state_code do
      context "#{state_code}: when there are 1099gs present" do
        let(:builder_class) { StateFile::StateInformationService.submission_builder_class(state_code) }
        let(:intake) { create("state_file_#{state_code}_intake".to_sym) }
        let(:submission) { create(:efile_submission, data_source: intake) }
        let!(:form1099g_1) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 100) }
        let!(:form1099g_2) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 200) }

        it "builds all 1099gs from intake" do
          xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)

          expect(xml.css("State1099G").count).to eq 2
        end
      end
    end
  end

  states_requiring_1099rs = StateFile::StateInformationService.active_state_codes.excluding(["id", "nc", "nj", "ny"])
  states_requiring_1099rs.each do |state_code|
    describe "#form1099rs", required_schema: state_code do
      context "#{state_code}: when there are 1099rs present" do
        let(:builder_class) { StateFile::StateInformationService.submission_builder_class(state_code) }
        let(:intake) { create("state_file_#{state_code}_intake".to_sym) }
        let(:submission) { create(:efile_submission, data_source: intake) }
        let!(:form1099r_1) { create(:state_file1099_r, intake: intake, state_tax_withheld_amount: 100) }
        let!(:form1099r_2) { create(:state_file1099_r, intake: intake, state_tax_withheld_amount: 200) }

        it "builds all 1099gs from intake" do
          xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)

          expect(xml.css("IRS1099R").count).to eq 2
        end
      end
    end
  end
end
