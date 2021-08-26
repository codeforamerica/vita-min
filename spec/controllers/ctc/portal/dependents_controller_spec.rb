require "rails_helper"

describe Ctc::Portal::DependentsController do
  context "#update" do
    let(:intake) { create :ctc_intake }
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

    around do |example|
      Timecop.freeze(DateTime.new(2021, 3, 4, 5, 10))
      example.run
      Timecop.return
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
          birth_date_year: '2013',
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
            "birth_date" => ["2012-05-01", "2013-05-01"],
            "ssn" => ["[REDACTED]", "[REDACTED]"],
          )
        })
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
        put :destroy, params: { id: dependent.id }
      end.not_to change(Dependent, :count)

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
