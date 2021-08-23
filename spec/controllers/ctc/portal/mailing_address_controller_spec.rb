require "rails_helper"

describe Ctc::Portal::MailingAddressController do
  context "#update" do
    let(:intake) do
      create(
        :ctc_intake,
        street_address: "123 Main St",
        street_address2: "STE 5",
        state: "TX",
        city: "Newton",
        zip_code: "77494"
      )
    end

    let(:params) {
      {
        ctc_mailing_address_form: {
          street_address: "123 Main St",
          street_address2: "STE 5",
          state: "TX",
          city: "Newton",
          zip_code: "77494"
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
        params[:ctc_mailing_address_form].merge!(
          street_address: "123 Bane St",
          city: "Gotham",
        )
      end

      it "creates a system note with redacted sensitive values" do
        put :update, params: params

        note = SystemNote::CtcPortalUpdate.last
        expect(note.client).to eq(intake.client)
        expect(note.data).to match({
          "model" => intake.to_global_id.to_s,
          "changes" => a_hash_including(
            "street_address" => ["123 Main St", "123 Bane St"],
            "city" => ["Newton", "Gotham"],
          )
        })
      end
    end
  end
end
