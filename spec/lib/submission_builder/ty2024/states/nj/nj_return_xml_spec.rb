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

    context "when filer has no spouse" do
      it "Exemptions are populated" do
        expect(xml.css('Exemptions').count).to eq(1)
      end

      it "populates line 6 XML fields" do
        expect(xml.at("Exemptions YouRegular").text).to eq("X")
        expect(xml.at("Exemptions SpouseCURegular").text).to eq("")
        expect(xml.at("Exemptions DomesticPartnerRegular").text).to eq("")
        expect(xml.at("Exemptions Line6").text).to eq("1000")
      end

      context "when filer is over 65" do
        let(:intake) { create(:state_file_nj_intake, :self_over_65) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver").text).to eq("")
          expect(xml.at("Exemptions Line7").text).to eq("1000")
        end
      end
      context "when filer is younger than 65" do
        let(:intake) { create(:state_file_nj_intake) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver").text).to eq("")
          expect(xml.at("Exemptions Line7").text).to eq("0")
        end
      end
    end

    context "when filer is married" do
      let(:intake) { create(:state_file_nj_intake, :married) }
      it "Exemptions are populated" do
        expect(xml.css('Exemptions').count).to eq(1)
      end

      it "populates line 6 XML fields" do
        expect(xml.at("Exemptions YouRegular").text).to eq("X")
        expect(xml.at("Exemptions SpouseCURegular").text).to eq("X")
        expect(xml.at("Exemptions DomesticPartnerRegular").text).to eq("")
        expect(xml.at("Exemptions Line6").text).to eq("2000")
      end

      context "when filer is over 65 and spouse is under 65" do
        let(:intake) { create(:state_file_nj_intake, :self_over_65, :married) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver").text).to eq("")
          expect(xml.at("Exemptions Line7").text).to eq("1000")
        end
      end

      context "when filer is over 65 and spouse is over 65" do
        let(:intake) { create(:state_file_nj_intake, :self_over_65, :married_spouse_over_65) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver").text).to eq("X")
          expect(xml.at("Exemptions Line7").text).to eq("2000")
        end
      end

      context "when filer is under 65 and spouse is under 65" do
        let(:intake) { create(:state_file_nj_intake, :married) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver").text).to eq("")
          expect(xml.at("Exemptions Line7").text).to eq("0")
        end
      end

      context "when filer is under 65 and spouse is over 65" do
        let(:intake) { create(:state_file_nj_intake, :married_spouse_over_65) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver").text).to eq("X")
          expect(xml.at("Exemptions Line7").text).to eq("1000")
        end
      end
    end
  end
end