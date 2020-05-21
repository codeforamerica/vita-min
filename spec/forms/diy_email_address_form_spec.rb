require "rails_helper"

RSpec.describe DiyEmailAddressForm do
  let(:diy_intake) { create :diy_intake }

  describe "validations" do
    it_behaves_like "email address validation", DiyEmailAddressForm do
      let(:form_object) { diy_intake }
    end
  end
end
