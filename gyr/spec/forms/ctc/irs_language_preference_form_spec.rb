require "rails_helper"

describe Ctc::IrsLanguagePreferenceForm do
  let(:intake) { create :intake, irs_language_preference: "english" }

  describe "#save" do
    let(:params) { { irs_language_preference: "vietnamese" } }

    it "saves the language preference" do
      form = described_class.new(intake, params)
      expect(form).to be_valid
      form.save
      intake.reload

      expect(intake.irs_language_preference).to eq("vietnamese")
    end
  end
end