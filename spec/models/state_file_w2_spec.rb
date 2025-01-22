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

  context "validation" do

    it "validates" do
      expect(w2).to be_valid
    end

    [:w2_index, :state_wages_amount, :state_income_tax_amount, :local_wages_and_tips_amount, :local_income_tax_amount, :box14_fli, :box14_stpickup, :box14_ui_hc_wd, :box14_ui_wf_swf, :wages].each do |field|
      context field do

        it "does not permit strings" do
          w2.send("#{field}=", "nope")
          expect(w2).not_to be_valid
          expect(w2.errors[field]).to be_present
        end

        it "does not permit values less than 0" do
          w2.send("#{field}=", -1)
          expect(w2).not_to be_valid
          expect(w2.errors[field]).to be_present
        end
      end
    end

    it "requires both locality_nm to be present if wages_and_tips_amt is present" do
      w2.locality_nm = nil
      expect(w2).not_to be_valid
      expect(w2.errors[:locality_nm]).to be_present
    end

    it "permits both locality_nm and local_wages_and_tips_amt to be missing" do
      w2.locality_nm = nil
      w2.local_wages_and_tips_amount = 0
      w2.local_income_tax_amount = 0
      expect(w2).to be_valid
    end

    it "requires local_income_tax_amt to be less than local_wages_and_tips_amt" do
      w2.local_wages_and_tips_amount = 0
      expect(w2).not_to be_valid
      expect(w2.errors[:local_income_tax_amount]).to be_present
    end

    it "requires state_income_tax_amt to be less than state_wages_amt" do
      w2.state_wages_amount = 0
      expect(w2).not_to be_valid
      expect(w2.errors[:state_income_tax_amount]).to be_present
    end

    it "permits state_wages_amt to be blank if state_income_tax_amt is blank" do
      w2.state_wages_amount = 0
      w2.state_income_tax_amount = 0
      expect(w2).to be_valid
    end

    it "requires employer_state_id_num to be present if state_income_tax_amt is present" do
      w2.employer_state_id_num = nil
      expect(w2).not_to be_valid
      expect(w2.errors[:employer_state_id_num]).to be_present
    end

    it "permits state_wages_amt to be blank if state_income_tax_amt is blank" do
      w2.employer_state_id_num = nil
      w2.state_wages_amount = 0
      w2.state_income_tax_amount = 0
      expect(w2).to be_valid
    end

    it "rejects localities without the correct prefix" do
      w2.locality_nm = "YONKERS"
      expect(w2).not_to be_valid
      expect(w2.errors[:locality_nm]).to be_present
    end

    it "permits localities prefixed with an approved value" do
      w2.locality_nm = "NYC JK ITS YONKERS"
      expect(w2).to be_valid
    end

    it "permits local_wages_and_tips_amt to be greater than w2.wagesAmt" do
      w2.local_wages_and_tips_amount = 1000000
      expect(w2).to be_valid
    end

    it "requires ein in the valid format" do
      w2.employer_ein = ''
      expect(w2).not_to be_valid
      expect(w2.errors[:employer_ein]).to be_present

      w2.employer_ein = 'RUTABAGA'
      expect(w2).not_to be_valid
      expect(w2.errors[:employer_ein]).to be_present

      w2.employer_ein = '123445678'
      expect(w2).to be_valid
      expect(w2.errors[:employer_ein]).not_to be_present
    end

    context "box 14 limit validation" do
      before do
        w2.check_box14_limits = true
        allow(StateFile::StateInformationService).to receive(:w2_supported_box14_codes)
          .and_return([
            { name: "UI_WF_SWF", limit: 179.78 },
            { name: "FLI", limit: 145.26 }
          ])
      end
  
      it "is invalid when box14_ui_wf_swf exceeds the state limit" do
        w2.box14_ui_wf_swf = 179.79
        expect(w2).not_to be_valid
        expect(w2.errors[:box14_ui_wf_swf]).to include(I18n.t("validators.dollar_limit", limit: '179.78'))
      end
  
      it "is invalid when box14_fli exceeds the state limit" do
        w2.box14_fli = 145.27
        expect(w2).not_to be_valid
        expect(w2.errors[:box14_fli]).to include(I18n.t("validators.dollar_limit", limit: '145.26'))
      end
  
      it "is valid when both box14_ui_wf_swf and box14_fli are within limits" do
        w2.box14_ui_wf_swf = 179.78
        w2.box14_fli = 145.26
        expect(w2).to be_valid
      end
    end
  end

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
end
