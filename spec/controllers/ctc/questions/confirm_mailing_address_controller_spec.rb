require "rails_helper"

describe Ctc::Questions::ConfirmMailingAddressController do
  let(:intake) { create :ctc_intake }
  before do
    sign_in intake.client
  end

  describe '#update' do
    it "redirects to ip_pin question" do
      put :update, {}
      expect(response).to redirect_to questions_ip_pin_path
    end
  end
end