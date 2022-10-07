require "rails_helper"

describe Ctc::Portal::W2s::EmployeeInfoController do
  let!(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    let(:creation_token) { ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base).generate("anything_is_ok") }
    let(:params) { { id: creation_token, "ctc_w2s_employee_info_form": {
      employee_city: "Los Angeles",
      employee_state: "CA",
      employee_zip_code: "90210",
      employee: "primary",
      employee_street_address: "123 main st",
      wages_amount: 123,
      federal_income_tax_withheld: 12
    }}}

    it "creates a W-2 and a system note" do
      expect {
        post :update, params: params
      }.to change { intake.w2s_including_incomplete.count }.by(1)
       .and change { SystemNote::CtcPortalAction.count }.by(1)

      system_note = SystemNote::CtcPortalAction.last
      expect(system_note.client).to eq(intake.client)
      expect(system_note.data).to match({
        'model' => intake.w2s_including_incomplete.last.to_global_id.to_s,
        'action' => 'created'
      })
    end
  end
end
