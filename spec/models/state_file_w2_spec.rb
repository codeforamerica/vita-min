# == Schema Information
#
# Table name: state_file_w2s
#
#  id                          :bigint           not null, primary key
#  box14_fli                   :decimal(12, 2)
#  box14_stpickup              :decimal(12, 2)
#  box14_ui_hc_wd              :decimal(12, 2)
#  box14_ui_wf_swf             :decimal(12, 2)
#  employee_name               :string
#  employee_ssn                :string
#  employer_ein                :string
#  employer_name               :string
#  employer_state_id_num       :string
#  local_income_tax_amount     :decimal(12, 2)
#  local_wages_and_tips_amount :decimal(12, 2)
#  locality_nm                 :string
#  state_file_intake_type      :string
#  state_income_tax_amount     :decimal(12, 2)
#  state_wages_amount          :decimal(12, 2)
#  w2_index                    :integer
#  wages                       :decimal(12, 2)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  state_file_intake_id        :bigint
#
# Indexes
#
#  index_state_file_w2s_on_state_file_intake  (state_file_intake_type,state_file_intake_id)
#

require "rails_helper"

describe StateFileW2 do
  let(:intake) { create :state_file_ny_intake }
  let(:w2) {
    create(:state_file_w2,
      employer_state_id_num: "001245788",
      employer_ein: '123445678',
      local_income_tax_amount: 200,
      local_wages_and_tips_amount: 8000,
      locality_nm: "NYC",
      state_file_intake: intake,
      state_income_tax_amount: 600,
      state_wages_amount: 8000,
      w2_index: 0
    )
  }

  describe "generating xml" do
    let(:intake) { create :state_file_md_intake, :df_data_2_w2s }

    it "Grabs the state code from the direct file W2" do
      xml = Nokogiri::XML(w2.state_tax_group_xml_node)
      expect(xml.at("StateAbbreviationCd").text).to eq "MD"
    end

    context "with a different state code on W2 State Tax Group" do
      before do
        intake.direct_file_data.w2s[0].StateAbbreviationCd = "AZ"
      end

      it "Grabs the state code from the direct file W2" do
        xml = Nokogiri::XML(w2.state_tax_group_xml_node)
        expect(xml.at("StateAbbreviationCd").text).to eq "AZ"
      end
    end

    context "when there is no StateAbbreviationCd on W2 from Direct File" do
      before do
        intake.direct_file_data.w2s[0].StateAbbreviationCd = ""
        intake.direct_file_data.w2s[1].StateAbbreviationCd = ""
      end

      it "hard codes a StateAbbreviationCd from intake" do
        xml = Nokogiri::XML(w2.state_tax_group_xml_node)
        expect(xml.at("StateAbbreviationCd").text).to eq('MD')
      end
    end

    context "with no EmployerStateIdNum" do
      before do
        intake.direct_file_data.w2s[0].EmployerStateIdNum = ""
      end

      it "does not leave StateAbbreviationCd empty" do
        xml = Nokogiri::XML(w2.state_tax_group_xml_node)
        expect(xml.at("StateAbbreviationCd").text).to eq "MD"
      end
    end
  end

  describe "box14_ui_wf_swf getter override" do
    context "box14_ui_wf_swf is nil but box14_ui_hc_wd is not" do
      it "returns value of box14_ui_hc_wd" do
        w2.box14_ui_wf_swf = nil
        w2.box14_ui_hc_wd = 100.00
        expect(w2.get_box14_ui_overwrite).to eq 100.00
      end
    end

    context "neither box14_ui_wf_swf nor box14_ui_hc_wd is nil" do
      it "returns value of box14_ui_wf_swf" do
        w2.box14_ui_wf_swf = 150.00
        w2.box14_ui_hc_wd = 100.00
        expect(w2.get_box14_ui_overwrite).to eq 150.00
      end
    end

    context "both box14_ui_wf_swf and box14_ui_hc_wd are nil" do
      it "returns nil" do
        w2.box14_ui_wf_swf = nil
        w2.box14_ui_hc_wd = nil
        expect(w2.get_box14_ui_overwrite).to be_nil
      end
    end
  end

  describe "self.find_limit" do
    context "when the limit is found" do
      before do
        allow(StateFile::StateInformationService).to receive(:w2_supported_box14_codes)
          .and_return([
            { name: "UI_WF_SWF", limit: 179.78 },
            { name: "FLI", limit: 145.26 }
          ])
      end

      it "returns the correct limit for a valid name" do
        expect(StateFileW2.find_limit("UI_WF_SWF", intake.state_code)).to eq(179.78)
        expect(StateFileW2.find_limit("FLI", intake.state_code)).to eq(145.26)
      end

      it "returns nil for an invalid name" do
        expect(StateFileW2.find_limit("NON_EXISTENT", intake.state_code)).to be_nil
      end
    end

    it "returns nil when empty array" do
      allow(StateFile::StateInformationService).to receive(:w2_supported_box14_codes).and_return([])
      expect(StateFileW2.find_limit("UI_WF_SWF", intake.state_code)).to be_nil
    end
  end
end
