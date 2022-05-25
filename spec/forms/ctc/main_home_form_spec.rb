require "rails_helper"

describe Ctc::MainHomeForm, requires_default_vita_partners: true do
  include_context :initial_ctc_form_context, additional_params: { home_location: "us_territory" }
  it_behaves_like :initial_ctc_form

  context "validations" do
    context "when home_location is selected" do
      it "is valid" do
        expect(
            described_class.new(Intake::CtcIntake.new, params)
        ).to be_valid
      end
    end

    context "when filing status is not selected" do
      it "is not valid" do
        expect(
            described_class.new(Intake::CtcIntake.new, { home_location: nil})
        ).not_to be_valid
      end
    end
  end
end