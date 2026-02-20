require "rails_helper"

RSpec.describe FileYourselfForm do
  let(:diy_intake) { DiyIntake.new }
  let(:additional_params) do
    {
      visitor_id: "visitor_1",
      source: "source",
      referrer: "referrer",
      locale: "es"
    }
  end

  describe "validations" do
    context "when all params are valid" do
      it "is valid" do
        form = described_class.new(diy_intake, additional_params)

        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    it "saves the right attributes to the record" do
      form = described_class.new(diy_intake, additional_params)
      form.save

      diy_intake.reload
      expect(diy_intake.source).to eq "source"
      expect(diy_intake.referrer).to eq "referrer"
      expect(diy_intake.visitor_id).to eq "visitor_1"
      expect(diy_intake.locale).to eq "es"
    end
  end
end
