require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::Documents::Nj1040, required_schema: "nj" do
  describe ".document" do
    let(:intake) { create(:state_file_nj_intake, filing_status: "single", municipality_code: "0101") }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:build_response) { described_class.build(submission, validate: false) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "includes municipality code with a prepending 0" do
      xml = described_class.build(submission).document
      expect(xml.document.at("CountyCode").to_s).to include("00101")
    end

    context "when filer has no spouse" do
      it "only adds single filing status child xml element" do
        expect(xml.document.at('FilingStatus').elements.length).to eq 1
        expect(xml.document.at('FilingStatus').elements[0].name).to eq "Single"
      end

      it "indicates single filing status with an X" do
        expect(xml.document.at('FilingStatus Single').text).to eq "X"
      end

      it "Exemptions are populated" do
        expect(xml.css('Exemptions').count).to eq(1)
      end

      it "populates line 6 XML fields" do
        expect(xml.at("Exemptions YouRegular").text).to eq("X")
        expect(xml.at("Exemptions SpouseCuRegular")).to eq(nil)
        expect(xml.at("Exemptions DomesticPartnerRegular")).to eq(nil)
      end

      context "when filer is over 65" do
        let(:intake) { create(:state_file_nj_intake, :primary_over_65) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver")).to eq(nil)
        end
      end

      context "when filer is younger than 65" do
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65")).to eq(nil)
          expect(xml.at("Exemptions SpouseCuPartner65OrOver")).to eq(nil)
        end
      end
    end

    context "when filer is married filing jointly" do
      let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
      it "Exemptions are populated" do
        expect(xml.css('Exemptions').count).to eq(1)
      end

      it "populates line 6 XML fields" do
        expect(xml.at("Exemptions YouRegular").text).to eq("X")
        expect(xml.at("Exemptions SpouseCuRegular").text).to eq("X")
        expect(xml.at("Exemptions DomesticPartnerRegular")).to eq(nil)
      end

      context "when filer is over 65 and spouse is under 65" do
        let(:intake) { create(:state_file_nj_intake, :primary_over_65, :married_filing_jointly) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver")).to eq(nil)
        end
      end

      context "when filer is over 65 and spouse is over 65" do
        let(:intake) { create(:state_file_nj_intake, :primary_over_65, :mfj_spouse_over_65) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65").text).to eq("X")
          expect(xml.at("Exemptions SpouseCuPartner65OrOver").text).to eq("X")
        end
      end

      context "when filer is under 65 and spouse is under 65" do
        let(:intake) { create(:state_file_nj_intake, :married_filing_jointly) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65")).to eq(nil)
          expect(xml.at("Exemptions SpouseCuPartner65OrOver")).to eq(nil)
        end
      end

      context "when filer is under 65 and spouse is over 65" do
        let(:intake) { create(:state_file_nj_intake, :mfj_spouse_over_65) }
        it "populates line 7 XML fields" do
          expect(xml.at("Exemptions YouOver65")).to eq(nil)
          expect(xml.at("Exemptions SpouseCuPartner65OrOver").text).to eq("X")
        end
      end

      it "only adds married filing jointly filing status child xml element" do
        expect(xml.document.at('FilingStatus').elements.length).to eq 1
        expect(xml.document.at('FilingStatus').elements[0].name).to eq "MarriedCuPartFilingJoint"
      end
      
      it "indicates married filing jointly status with an X" do
        expect(xml.document.at('FilingStatus MarriedCuPartFilingJoint').text).to eq "X"
      end
    end

    context "married filing separately filers" do
      let(:intake) { create(:state_file_nj_intake, :married_filing_separately) }

      it "only adds married filing separately filing status child xml element" do
        expect(xml.document.at('FilingStatus').elements.length).to eq 1
        expect(xml.document.at('FilingStatus').elements[0].name).to eq "MarriedCuPartFilingSeparate"
      end
      
      it "fills married filing separately status spouse fields for ssn and name" do
        expect(xml.document.at('FilingStatus MarriedCuPartFilingSeparate SpouseSSN').text).to eq(intake.spouse.ssn)
        expect(xml.document.at('FilingStatus MarriedCuPartFilingSeparate SpouseName FirstName').text).to eq(intake.spouse.first_name)
        expect(xml.document.at('FilingStatus MarriedCuPartFilingSeparate SpouseName MiddleInitial').text).to eq(intake.spouse.middle_initial)
        expect(xml.document.at('FilingStatus MarriedCuPartFilingSeparate SpouseName LastName').text).to eq(intake.spouse.last_name)
      end
    end

    context "qualifying widow/er filers" do
      let(:intake) { create(:state_file_nj_intake, filing_status: "qualifying_widow") }
      
      context "when spouse passed last year" do
        before do
          date_within_prior_year = "#{MultiTenantService.new(:statefile).current_tax_year}-09-30"
          submission.data_source.direct_file_data.spouse_date_of_death = date_within_prior_year
        end
  
        it "only adds the qualifying widow/er filing status child xml element" do
          expect(xml.document.at('FilingStatus').elements.length).to eq 1
          expect(xml.document.at('FilingStatus').elements[0].name).to eq "QualWidOrWider"
        end

        it "indicates filing status with an X and indicates that spouse passed last tax year" do
          expect(xml.document.at('FilingStatus QualWidOrWider QualWidOrWiderSurvCuPartner').text).to eq "X"
          expect(xml.document.at('FilingStatus QualWidOrWider LastYear').text).to eq "X"
          expect(xml.document.at('FilingStatus QualWidOrWider').elements.length).to eq 2
        end
      end

      context "when spouse passed two years prior" do
        before do
          date_within_prior_year = "#{MultiTenantService.new(:statefile).current_tax_year - 1}-09-30"
          submission.data_source.direct_file_data.spouse_date_of_death = date_within_prior_year
        end
  
        it "only adds the qualifying widow/er filing status child xml element" do
          expect(xml.document.at('FilingStatus').elements.length).to eq 1
          expect(xml.document.at('FilingStatus').elements[0].name).to eq "QualWidOrWider"
        end

        it "indicates filing status with an X and indicates that spouse passed last tax year" do
          expect(xml.document.at('FilingStatus QualWidOrWider QualWidOrWiderSurvCuPartner').text).to eq "X"
          expect(xml.document.at('FilingStatus QualWidOrWider TwoYearPrior').text).to eq "X"
          expect(xml.document.at('FilingStatus QualWidOrWider').elements.length).to eq 2
        end
      end
    end    
  end
end