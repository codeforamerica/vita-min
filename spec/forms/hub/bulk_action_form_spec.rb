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
end
