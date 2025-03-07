require 'rails_helper'

RSpec.describe StateFile::NcCountyForm, type: :model do

  describe "residence_county validations" do
    let(:intake) { create :state_file_nc_intake }
    let(:form) { described_class.new(intake, params) }
    let(:params) {
      { residence_county: residence_county }
    }
    let(:residence_county) { nil }

    context "when residence_county is not provided" do
      it "is invalid" do
        expect(form.valid?).to be false
        expect(form.errors[:residence_county]).to eq([I18n.t("forms.errors.nc_county.county.presence")])
      end
    end

    context "when residence_county is not included" do
      let(:residence_county) { "120" }
      it "is invalid" do
        expect(form.valid?).to be false
        expect(form.errors[:residence_county]).to eq([I18n.t("forms.errors.nc_county.county.presence")])
      end
    end

    context "when residence_county is included and provided" do
      let(:residence_county) { "003" }
      it "is valid" do
        expect(form.valid?).to be true
      end
    end
  end

  describe "#save" do
    context "when residence county is in a designated hurricane relief county" do
      it "should assign residence_county to intake and not require other county fields" do
        intake = create(:state_file_nc_intake)
        form = StateFile::NcCountyForm.from_intake(intake)
        form.residence_county = "011"
        expect { form.save }.to change(intake, :residence_county).to("011")
      end
    end

    context "when residence county is not in a designated hurricane relief county" do
      let(:params) do
        {
          residence_county: "001",
          moved_after_hurricane_helene: moved,
          county_during_hurricane_helene: county_during_hurricane_helene
        }
      end
      let(:moved) { "" }
      let(:county_during_hurricane_helene) { "" }

      context "when moved after hurricane question is not answered" do
        it "fails and requires moved_after_hurricane_helene field" do
          intake = create(:state_file_nc_intake)
          form = described_class.new(intake, params)
          expect(form.valid?).to be false
        end
      end

      context "when moved after hurricane question is no" do
        let(:moved) { "no" }

        it "form is valid" do
          intake = create(:state_file_nc_intake)
          form = described_class.new(intake, params)
          expect(form.valid?).to be true
        end
      end

      context "when moved after hurricane question is yes" do
        let(:moved) { "yes" }

        context "when no county_during_hurricane_helene selected" do
          it "form is not valid" do
            intake = create(:state_file_nc_intake)
            form = described_class.new(intake, params)
            expect(form.valid?).to be false
            expect(form.errors[:county_during_hurricane_helene]).to eq([I18n.t("forms.errors.nc_county.county.presence")])
          end
        end

        context "when county_during_hurricane_helene is selected" do
          let(:county_during_hurricane_helene) { "011" }

          it "form is valid" do
            intake = create(:state_file_nc_intake)
            form = described_class.new(intake, params)
            expect(form.valid?).to be true
          end
        end
      end
    end
  end
end
