require "rails_helper"

describe Ctc::Portal::SpouseController do
  context "#update" do
    let(:intake) do
      create :ctc_intake,
             spouse_first_name: "Marty",
             spouse_middle_initial: "J",
             spouse_last_name: "Mango",
             spouse_birth_date: Date.parse("1963-09-10"),
             spouse_ssn: "111-22-8888",
             spouse_last_four_ssn: "8888",
             spouse_tin_type: "ssn"
    end

    let(:params) {
      {
        ctc_portal_spouse_form: {
          spouse_first_name: "Marty",
          spouse_middle_initial: "J",
          spouse_last_name: "Mango",
          spouse_birth_date_year: "1963",
          spouse_birth_date_month: "9",
          spouse_birth_date_day: "10",
          spouse_ssn: "111-22-8888",
          spouse_ssn_confirmation: "111-22-8888",
          spouse_tin_type: "ssn",
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

    context "when there are changes of note" do
      before do
        params[:ctc_portal_spouse_form].merge!(
          spouse_first_name: 'Martin',
          spouse_last_name: 'Mangonada',
          spouse_birth_date_year: '2013',
          spouse_ssn: '111-22-8889',
          spouse_ssn_confirmation: '111-22-8889',
        )
      end

      it "creates a system note with redacted sensitive values" do
        put :update, params: params

        note = SystemNote::CtcPortalUpdate.last
        expect(note.client).to eq(intake.client)
        expect(note.data).to match({
          "model" => intake.to_global_id.to_s,
          "changes" => a_hash_including(
            "spouse_first_name" => ["Marty", "Martin"],
            "spouse_last_name" => ["Mango", "Mangonada"],
            "spouse_ssn" => ["[REDACTED]", "[REDACTED]"],
            "spouse_last_four_ssn" => ["[REDACTED]", "[REDACTED]"],
          )
        })
      end
    end
  end
end
