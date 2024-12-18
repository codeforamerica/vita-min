require "rails_helper"

describe Ctc::Portal::DependentsController do
  let(:intake) { client.intake }
  let(:client) { create :client, intake: (build :ctc_intake), tax_returns: [(build :ctc_tax_return)] }
  let(:dependent) do
    create(
      :qualifying_child,
      intake: intake,
      first_name: "Maggie",
      middle_initial: "M",
      last_name: "Mango",
      birth_date: Date.parse("2012-05-01"),
      tin_type: "ssn",
      ssn: '111-22-9999',
      has_ip_pin: "no"
    )
  end

  let(:params) {
    {
      id: dependent.id,
      ctc_portal_dependent_form: {
        first_name: "Maggie",
        middle_initial: "M",
        last_name: "Mango",
        birth_date_year: "2012",
        birth_date_month: "5",
        birth_date_day: "1",
        tin_type: "ssn",
        ssn: '111-22-9999',
        ssn_confirmation: "111-22-9999",
      }
    }
  }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "renders edit template" do
      get :edit, params: params
      expect(response).to render_template :edit
    end
  end

  context "#update" do
    around do |example|
      Timecop.freeze(DateTime.new(2021, 3, 4, 5, 10)) do
        example.run
      end
    end

    it "does not make a system note if nothing significant changed" do
      expect do
        put :update, params: params
      end.not_to change(SystemNote::CtcPortalUpdate, :count)
    end

    it "changes has_ip_pin if an ip pin is provided" do
      params[:ctc_portal_dependent_form].merge!(
        ip_pin: '123456',
      )
      expect do
        put :update, params: params
      end.to change { dependent.reload.has_ip_pin }.from("no").to("yes")
      expect(dependent.ip_pin).to eq('123456')
    end

    context "when there are changes of note" do
      before do
        params[:ctc_portal_dependent_form].merge!(
          first_name: 'Margaret',
          last_name: 'Mangosteen',
          birth_date_month: '12',
          ssn: '111-22-8881',
          ssn_confirmation: '111-22-8881',
        )
      end

      it "creates a system note with redacted sensitive values" do
        put :update, params: params

        note = SystemNote::CtcPortalUpdate.last
        expect(note.client).to eq(intake.client)
        expect(note.data).to match({
          "model" => dependent.to_global_id.to_s,
          "changes" => a_hash_including(
            "first_name" => ["Maggie", "Margaret"],
            "last_name" => ["Mango", "Mangosteen"],
            "birth_date" => ["2012-05-01", "2012-12-01"],
            "ssn" => ["[REDACTED]", "[REDACTED]"],
          )
        })
      end
    end

    context "when the changes are invalid" do
      render_views

      let(:params) {
        {
          id: dependent.id,
          ctc_portal_dependent_form: {
            invalid_params: "very invalid"
          }
        }
      }

      it "renders edit template" do
        put :update, params: params

        expect(assigns(:form).errors).not_to be_blank
        expect(response).to be_ok
        expect(response).to render_template :edit
      end
    end
  end

  context "#destroy" do
    let(:intake) { create :ctc_intake }
    let!(:dependent) { create(:qualifying_child, intake: intake) }

    before do
      sign_in intake.client
    end

    it "removes a dependent and leaves a system note" do
      expect do
        expect do
          put :destroy, params: { id: dependent.id }
        end.to change(Dependent, :count).by(-1)
      end.not_to change { Dependent.with_deleted.count }

      expect(dependent.reload.soft_deleted_at).to be_truthy

      system_note = SystemNote::CtcPortalAction.last
      expect(system_note.client).to eq(intake.client)
      expect(system_note.data).to match({
        'model' => dependent.to_global_id.to_s,
        'action' => 'removed'
      })
    end
  end
end
