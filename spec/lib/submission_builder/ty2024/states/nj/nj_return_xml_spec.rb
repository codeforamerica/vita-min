require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::NjReturnXml, required_schema: "nj" do
  describe '.build' do
    let(:intake) { create(:state_file_nj_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
    let(:xml) { Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml) }

    it "generates basic components of return" do
      expect(xml.document.root.namespaces).to include({ "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" })
      expect(xml.document.at('AuthenticationHeader').to_s).to include('xmlns="http://www.irs.gov/efile"')
      expect(xml.document.at('ReturnHeaderState').to_s).to include('xmlns="http://www.irs.gov/efile"')
    end

    it "includes attached documents" do
      expect(xml.document.at('ReturnDataState FormNJ1040 Header')).to be_an_instance_of Nokogiri::XML::Element
    end

    describe 'dependents' do
      context 'when no dependents' do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

        it 'does not include dependents section' do
          expect(xml.at("Dependents")).to eq(nil)
        end
      end

      context 'when many dependents' do
        let(:intake) { create(:state_file_nj_intake, :df_data_many_deps) }

        before do
          intake.dependents.each_with_index do |dependent, i|
            dependent.update(
              dob: i.years.ago(Date.new(2020, 1, 1)),
              first_name: "Firstname#{i}",
              last_name: "Lastname#{i}",
              middle_initial: 'ABCDEFGHIJK'[i],
              suffix: 'JR',
              ssn: "0000000#{"%02d" % i}"
            )
          end
        end

        it 'includes each dependent names, SSN, and year of birth to a maximum of 10' do
          expect(xml.css("Dependents").count).to eq(10)

          first_dep = xml.css("Dependents")[0]
          first_dep_name = first_dep.at("DependentsName")
          first_dep_ssn = first_dep.at("DependentsSSN")
          first_dep_birth_year = first_dep.at("BirthYear")
          expect(first_dep_name.at("FirstName").text).to eq("Firstname0")
          expect(first_dep_name.at("LastName").text).to eq("Lastname0")
          expect(first_dep_name.at("MiddleInitial").text).to eq("A")
          expect(first_dep_name.at("NameSuffix").text).to eq("JR")
          expect(first_dep_ssn.text).to eq("000000000")
          expect(first_dep_birth_year.text).to eq("2020")

          last_dep = xml.css("Dependents")[9]
          last_dep_name = last_dep.at("DependentsName")
          last_dep_ssn = last_dep.at("DependentsSSN")
          last_dep_birth_year = last_dep.at("BirthYear")
          expect(last_dep_name.at("FirstName").text).to eq("Firstname9")
          expect(last_dep_name.at("LastName").text).to eq("Lastname9")
          expect(last_dep_name.at("MiddleInitial").text).to eq("J")
          expect(last_dep_name.at("NameSuffix").text).to eq("JR")
          expect(last_dep_ssn.text).to eq("000000009")
          expect(last_dep_birth_year.text).to eq("2011")
        end
      end
    end

    describe "wages" do
      context "when no w2 wages (line 15 is -1)" do
        let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

        it "does not include WagesSalariesTips item" do
          expect(xml.at("WagesSalariesTips")).to eq(nil)
        end
      end

      context "when w2 wages exist" do
        let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }

        it "includes the sum in WagesSalariesTips item" do
          expected_sum = (50000.33 + 50000.33 + 50000.33 + 50000.33).round
          expect(xml.at("WagesSalariesTips").text).to eq(expected_sum.to_s)
        end
      end
    end
  end
end
