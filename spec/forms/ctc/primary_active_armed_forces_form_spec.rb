require "rails_helper"

describe Ctc::PrimaryActiveArmedForcesForm do
  let(:intake) { create :ctc_intake }

  let(:params) do
    {
      primary_active_armed_forces: "no"
    }
  end

  context "save" do
    it "persists fields to the intake" do
      expect {
        described_class.new(intake, params).save
      }.to change(intake, :primary_active_armed_forces).from("unfilled").to("no")
    end
  end
end