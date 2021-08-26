require "rails_helper"

describe Ctc::Portal::PrimaryFilerController do
  context "#update" do
    let(:intake) do
      create :ctc_intake,
             primary_first_name: "Marty",
             primary_middle_initial: "J",
             primary_last_name: "Mango",
             primary_birth_date: Date.parse("1963-09-10"),
             primary_ssn: "111-22-8888",
             primary_last_four_ssn: "8888",
             primary_tin_type: "ssn",
             has_primary_ip_pin: "no"
    end

    let(:params) {
      {
        ctc_portal_primary_filer_form: {
          primary_first_name: "Marty",
          primary_middle_initial: "J",
          primary_last_name: "Mango",
          primary_birth_date_year: "1963",
          primary_birth_date_month: "9",
          primary_birth_date_day: "10",
          primary_ssn: "111-22-8888",
          primary_ssn_confirmation: "111-22-8888",
          primary_tin_type: "ssn",
        }
      }
    }

    before do
      sign_in intake.client
    end

    it "does not make a system note if nothing significant changed" do
      expect do
        put :update, params: params
      end.not_to change(SystemNote::CtcPortalUpdate, :count)
    end

    it "changes has_primary_ip_pin if an ip pin is provided" do
      params[:ctc_portal_primary_filer_form].merge!(
        primary_ip_pin: '123456',
      )
      expect do
        put :update, params: params
      end.to change { intake.reload.has_primary_ip_pin }.from("no").to("yes")
      expect(intake.primary_ip_pin).to eq('123456')
    end

    context "when there are changes of note" do
      before do
        params[:ctc_portal_primary_filer_form].merge!(
          primary_first_name: 'Martin',
          primary_last_name: 'Mangonada',
          primary_birth_date_year: '2013',
          primary_ssn: '111-22-8889',
          primary_ssn_confirmation: '111-22-8889',
        )
      end

      it "creates a system note with redacted sensitive values" do
        put :update, params: params

        note = SystemNote::CtcPortalUpdate.last
        expect(note.client).to eq(intake.client)
        expect(note.data).to match({
          "model" => intake.to_global_id.to_s,
          "changes" => a_hash_including(
            "primary_first_name" => ["Marty", "Martin"],
            "primary_last_name" => ["Mango", "Mangonada"],
            "primary_ssn" => ["[REDACTED]", "[REDACTED]"],
            "primary_last_four_ssn" => ["[REDACTED]", "[REDACTED]"],
          )
        })
      end
    end
  end
end
