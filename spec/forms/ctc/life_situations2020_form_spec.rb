require "rails_helper"

describe Ctc::LifeSituations2020Form do
  let(:intake) { create :ctc_intake }

  let(:params) do
    {
      cannot_claim_me_as_a_dependent: "yes",
      primary_active_armed_forces: "no"
    }
  end

  context "save" do
    it "persists address fields to the intake" do
      expect {
        described_class.new(intake, params).save
      }.to change(intake, :cannot_claim_me_as_a_dependent).from("unfilled").to("yes")
                                                          .and change(intake, :primary_active_armed_forces).from("unfilled").to("no")
    end
  end
end