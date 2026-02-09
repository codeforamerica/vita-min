require "rails_helper"

RSpec.describe EligibilityStateForm do
  let(:intake) { create :intake }
  let(:service_preference) { "diy" }
  let(:params) do
    {
      service_preference: service_preference
    }
  end

  describe "validations" do
    describe '#service_preference' do
      context "when params includes an empty value" do
        let(:service_preference) { nil }

        it "does not pass validation" do
          form = described_class.new(intake, params)
          expect(form).not_to be_valid
          expect(form.errors[:service_preference]).to be_present
        end
      end

      context "when params includes a valid value" do
        let(:service_preference) { "diy" }

        it "passes validation" do
          expect(described_class.new(intake, params)).to be_valid
        end
      end
    end
  end

  describe "#save" do
    let(:intake) { create :intake }
    let(:params) do
      {
        service_preference: "diy"
      }
    end

    it "updates the intake" do
      described_class.new(intake, params).save

      intake.reload
      expect(intake.service_preference).to eq "diy"
    end
  end
end