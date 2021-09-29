require "rails_helper"

describe Intake::GyrIntake do
  describe "after_save when the intake is completed" do
    let(:intake) { create :intake }

    it_behaves_like "an incoming interaction" do
      let(:subject) { create :intake }
      before { subject.completed_at = Time.now }
    end
  end

  describe "after_save when the intake has already been completed" do
    it_behaves_like "an internal interaction" do
      let(:subject) { create :intake, completed_at: Time.now }
    end
  end
end