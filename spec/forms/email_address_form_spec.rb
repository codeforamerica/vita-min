require "rails_helper"

RSpec.describe EmailAddressForm do
  let(:intake) { create :intake }

  describe "validations" do
    it_behaves_like "email address validation", EmailAddressForm do
      let(:form_object) { intake }
    end
  end
end
