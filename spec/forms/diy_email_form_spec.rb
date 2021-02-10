require "rails_helper"

describe DiyEmailForm do
  describe "validations" do
    it_behaves_like "email address validation", described_class do
      let(:form_object) { build :diy_intake }
    end
  end
end