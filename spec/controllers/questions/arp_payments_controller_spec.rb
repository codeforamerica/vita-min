require "rails_helper"

describe Questions::ArpPaymentsController do
  let(:intake) { create :intake }

  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :edit
    it_behaves_like :a_get_action_redirects_for_show_still_needs_help_clients, action: :edit
  end

  describe "#update" do
    before do
      sign_in intake.client
    end

    context "with necessary params" do
      let(:params) do
        { arp_payments_form: {
            eip1_amount_received: 100,
            eip2_amount_received: "300",
            eip3_amount_received: 100,
            received_stimulus_payment: "unfilled",
        }}
      end
      it "updates the intake with the values" do
        put :update, params: params
        intake.reload
        expect(intake.eip1_amount_received).to eq 100
        expect(intake.eip2_amount_received).to eq 300
        expect(intake.eip3_amount_received).to eq 100
        expect(intake.received_stimulus_payment).to eq "yes"
      end
    end
  end
end