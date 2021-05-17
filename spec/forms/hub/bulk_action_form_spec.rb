require "rails_helper"

RSpec.describe Hub::BulkActionForm do
  let(:vita_partner) { create :organization }
  let(:tax_return_selection) { create :tax_return_selection }
  let(:form) { Hub::BulkActionForm.new(tax_return_selection, form_params) }

  describe "#valid?" do
    describe "#no_missing_message_locales" do
      context "when clients with both locales exist but one is missing" do
        let!(:client_en) { create :client, intake: create(:intake, locale: "en"), tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])] }
        let!(:client_es) { create :client, intake: create(:intake, locale: "es"), tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])] }
        let(:form_params) do
          {
            vita_partner_id: vita_partner.id,
            message_body_en: "a message in english, obvs",
            message_body_es: " ",
          }
        end

        it "adds an error to the object" do
          expect(form).not_to be_valid
          expect(form.errors[:message_body_es]).to include "Please include a message for clients who prefer Spanish."
        end
      end

      context "with clients using both locales and no message bodies submitted for any locale" do
        let!(:client_en) { create :client, intake: create(:intake, locale: "en"), tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])] }
        let!(:client_es) { create :client, intake: create(:intake, locale: "es"), tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])] }
        let(:form_params) do
          {
            vita_partner_id: vita_partner.id,
            message_body_en: " \n",
            message_body_es: " ",
          }
        end

        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "with clients who prefer only one locale and a message for that locale" do
        let!(:client_en) { create :client, intake: create(:intake, locale: "en"), tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])] }
        let(:form_params) do
          {
            vita_partner_id: vita_partner.id,
            message_body_en: "a message for the client",
            message_body_es: " ",
          }
        end

        it "is valid" do
          expect(form).to be_valid
        end
      end
    end

    context "with message bodies over 900 characters" do
      let(:form_params) do
        {
          vita_partner_id: vita_partner.id,
          message_body_en: "omgosh" * 450,
          message_body_es: "¡dios mío!" * 450,
        }
      end

      it "adds a validation error to that message body" do
        expect(form).not_to be_valid
        expect(form.errors[:message_body_en]).to include "Please limit your message to 900 characters"
        expect(form.errors[:message_body_es]).to include "Please limit your message to 900 characters"
      end
    end
  end

  describe "setting default values" do
    context "default message body" do
      let(:intake_en) { create(:intake, locale: "en", preferred_name: "Luna Lemon") }
      let(:intake_es) { create(:intake, locale: "es", preferred_name: "Robby Radish") }
      let!(:client_en) { create :client, intake: intake_en, tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])] }
      let!(:client_es) { create :client, intake: intake_es, tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])] }

      context "when a message body is provided" do
        let(:form_params) do
          {
            message_body_en: "a message in english, obvs",
            message_body_es: "a message in spanish, obvs",
          }
        end

        it "does not overwrite the message body" do
          expect(form.message_body_en).to eq "a message in english, obvs"
          expect(form.message_body_es).to eq "a message in spanish, obvs"
        end
      end

      context "when a status and message body are not provided" do
        let(:form_params) do
          {
            status: nil,
            message_body_en: "",
            message_body_es: "",
          }
        end

        it "sets message body as an empty string" do
          expect(form.message_body_en).to eq ""
          expect(form.message_body_es).to eq ""
        end
      end

      context "when a status that has a message template is provided" do
        let(:form_params) do
          {
            status: "intake_info_requested",
            message_body_en: "",
            message_body_es: "",
          }
        end

        it "sets message body to the template" do
          expect(form.message_body_en).to start_with("Hello")
          expect(form.message_body_es).to start_with("¡Hola")
        end
      end

      context "when a status without a message template is provided" do
        let(:form_params) do
          {
            status: "non_matching_status",
            message_body_en: "",
            message_body_es: "",
          }
        end

        it "sets message body as an empty string" do
          expect(form.message_body_en).to eq ""
          expect(form.message_body_es).to eq ""
        end
      end
    end
  end
end
