require "rails_helper"

RSpec.describe StateFile::Questions::NyW2Controller do
  let(:raw_direct_file_data) { File.read(Rails.root.join("spec/fixtures/files/fed_return_batman_ny.xml")) }
  let(:direct_file_xml) { Nokogiri::XML(raw_direct_file_data) }
  let(:intake) do
    create :state_file_ny_intake, raw_direct_file_data: direct_file_xml.to_xml
  end
  before do
    sign_in intake
  end

  describe ".show?" do
    context "they have no issues with their fed xml w2s" do
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "with a broken w2" do
      context "StateWagesAmt is blank or missing" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("StateWagesAmt").content = ""
          xml
        end

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "LocalWagesAndTipsAmt is missing" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalWagesAndTipsAmt").content = ""
          xml.at("LocalIncomeTaxAmt").content = ""
          xml
        end

        context "client indicated they were a full year NYC resident" do
          it "returns true" do
            intake.update(nyc_residency: :full_year)
            expect(described_class.show?(intake)).to eq true
          end
        end

        context "client was not an NYC resident" do
          it "returns false" do
            intake.update(nyc_residency: :none)
            expect(described_class.show?(intake)).to eq false
          end
        end
      end

      context "client indicated they were an NYC resident on nyc-residency and LocalityNm is missing" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalityNm").content = ""
          xml
        end

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "LocalityNm is blank" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalityNm").content = ""
          xml
        end
        before do
          intake.update(nyc_residency: :none)
        end

        context "LocalWagesAndTipsAmt is present" do
          let(:direct_file_xml) do
            xml = super()
            xml.at("LocalIncomeTaxAmt").content = ""
            xml
          end

          it "returns true" do
            expect(described_class.show?(intake)).to eq true
          end
        end

        context "LocalIncomeTaxAmt is present" do
          let(:direct_file_xml) do
            xml = super()
            xml.at("LocalWagesAndTipsAmt").content = ""
            xml
          end

          it "returns true" do
            expect(described_class.show?(intake)).to eq true
          end
        end

        context "neither LocalWagesAndTipsAmt nor LocalIncomeTaxAmt is present" do
          let(:direct_file_xml) do
            xml = super()
            xml.at("LocalWagesAndTipsAmt").content = ""
            xml.at("LocalIncomeTaxAmt").content = ""
            xml
          end

          it "returns false" do
            expect(described_class.show?(intake)).to eq false
          end
        end
      end

      context "LocalIncomeTaxAmt is present but LocalWagesAndTipsAmt is not" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalWagesAndTipsAmt").content = ""
          xml
        end

        it "returns true" do
          intake.update(nyc_residency: :none)
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "StateIncomeTaxAmt is present but StateWagesAmt is not" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("StateWagesAmt").content = ""
          xml
        end

        it "returns true" do
          intake.update(nyc_residency: :none)
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "StateWagesAmt is present but EmployerStateIdNum is not" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("EmployerStateIdNum").content = ""
          xml
        end

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "LocalityNm does not match one of the NY Pub 93 list of allowed values" do
        let(:direct_file_xml) do
          xml = super()
          xml.at("LocalityNm").content = "Not New York"
          xml
        end

        it "returns true" do
          intake.update(nyc_residency: :none)
          expect(described_class.show?(intake)).to eq true
        end
      end
    end
  end
end