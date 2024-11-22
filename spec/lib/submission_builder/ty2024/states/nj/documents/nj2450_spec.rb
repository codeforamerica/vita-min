require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::Documents::Nj2450, required_schema: "nj" do
  describe ".document" do
    let(:intake) { create(:state_file_nj_intake, :df_data_mfj) }
    let(:primary_ssn_from_fixture) { intake.primary.ssn }
    let(:spouse_ssn_from_fixture) { intake.spouse.ssn }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: true, kwargs: { primary_or_spouse: :primary }) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    after do
      expect(build_response.errors).not_to be_present
    end

    context "primary" do
      let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_ui_hc_wd: 99, box14_fli: 100, employer_ein: '123456789', wages: '999') }
      let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: primary_ssn_from_fixture, box14_ui_hc_wd: 134, box14_fli: 123, employer_ein: '923456781', wages: '888') }  

      it "fills body for each w2" do
        body_elements = xml.css("Body")
        expect(body_elements.count).to eq 2

        body_elements.each do |body|
          w2 = [w2_1, w2_2].find { |test_w2| test_w2.employer_ein == body.at('FedEmployerId').text}

          expect(body.at('EmployerName').text).to eq(w2.employer_name)
          expect(body.at('Wages').text).to eq(w2.wages.round.to_s)
          expect(body.at('Deductions ColumnA').text).to eq(w2.box14_ui_hc_wd.round.to_s)
          expect(body.at('Deductions ColumnC').text).to eq(w2.box14_fli.round.to_s)
          expect(body.at('FilerIndicator').text).to eq('T')
        end
      end

      it "adds column a total and excess" do
        expect(xml.at("ColumnATotal").text).to eq("233")
        expect(xml.at("ColumnAExcess").text).to eq("53")
      end

      it "adds column c total and excess" do
        expect(xml.at("ColumnCTotal").text).to eq("223")
        expect(xml.at("ColumnCExcess").text).to eq("78")
      end
    end

    context "spouse" do
      let!(:w2_1) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_ui_hc_wd: 99, box14_fli: 100, employer_ein: '123456789', wages: '999') }
      let!(:w2_2) { create(:state_file_w2, state_file_intake: intake, employee_ssn: spouse_ssn_from_fixture, box14_ui_hc_wd: 134, box14_fli: 123, employer_ein: '923456781', wages: '888') }
      let(:build_response) { described_class.build(submission, validate: true, kwargs: { primary_or_spouse: :spouse}) }

      it "fills body for each w2" do
        body_elements = xml.css("Body")
        expect(body_elements.count).to eq 2

        body_elements.each do |body|
          w2 = [w2_1, w2_2].find { |test_w2| test_w2.employer_ein == body.at('FedEmployerId').text}

          expect(body.at('EmployerName').text).to eq(w2.employer_name)
          expect(body.at('Wages').text).to eq(w2.wages.round.to_s)
          expect(body.at('Deductions ColumnA').text).to eq(w2.box14_ui_hc_wd.round.to_s)
          expect(body.at('Deductions ColumnC').text).to eq(w2.box14_fli.round.to_s)
          expect(body.at('FilerIndicator').text).to eq('S')
        end
      end

      it "adds column a total and excess" do
        expect(xml.at("ColumnATotal").text).to eq("233")
        expect(xml.at("ColumnAExcess").text).to eq("53")
      end

      it "adds column c total and excess" do
        expect(xml.at("ColumnCTotal").text).to eq("223")
        expect(xml.at("ColumnCExcess").text).to eq("78")
      end
    end
  end
end