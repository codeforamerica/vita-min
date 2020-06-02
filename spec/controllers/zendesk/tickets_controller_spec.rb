require "rails_helper"

RSpec.describe Zendesk::TicketsController do
  let(:ticket_id) { 123 }
  let(:user) { create :user, provider: "zendesk" }
  let(:ticket) { double("ZendeskAPI::Ticket", id: ticket_id, subject: "Oswald Orange") }
  let!(:intake) { create :intake, intake_ticket_id: ticket_id }
  let!(:id_document) { create :document, :with_upload, intake: intake, document_type: "ID" }
  let!(:w2_document) { create :document, :with_upload, intake: intake, document_type: "W-2" }

  describe "#show" do
    it_behaves_like :a_protected_zendesk_ticket_page do
      let(:valid_params) do
        { id: ticket_id }
      end
    end

    context "as an authenticated zendesk user with ticket access" do
      render_views

      before do
        allow(subject).to receive(:current_user).and_return(user)
        allow(subject).to receive(:current_ticket).and_return(ticket)
      end

      context "with one intake" do
        it "shows all documents for the intake based on ticket id" do
          get :show, params: { id: ticket_id }

          expect(assigns(:ticket)).to eq ticket
          expect(assigns(:intakes)).to contain_exactly(intake)
          expect(assigns(:document_groups).values.flatten.map(&:__getobj__))
            .to contain_exactly(id_document, w2_document)
          expect(response.body).to include(pdf_zendesk_intake_path(intake.id, filename: intake.intake_pdf_filename))
          expect(response.body).to include(consent_pdf_zendesk_intake_path(
                                             intake.id, filename: intake.consent_pdf_filename))
          expect(response.body).to include(zendesk_document_path(id_document.id))
          expect(response.body).to include(zendesk_document_path(w2_document.id))
        end
      end

      context "with duplicate linked intakes" do
        let!(:duplicate_intake) { create :intake, intake_ticket_id: ticket_id }
        let!(:duplicate_id_document) { create :document, :with_upload, intake: intake, document_type: "ID" }
        let!(:duplicate_w2_document) { create :document, :with_upload, intake: intake, document_type: "W-2" }

        it "shows all documents for all intakes with that ticket id" do
          get :show, params: { id: ticket_id }

          expect(assigns(:ticket)).to eq ticket
          expect(assigns(:intakes)).to contain_exactly(intake, duplicate_intake)
          contain_exactly(id_document, duplicate_id_document, w2_document, duplicate_w2_document)

          expect(response.body).to include(pdf_zendesk_intake_path(intake.id, filename: intake.intake_pdf_filename))
          expect(response.body).to include(consent_pdf_zendesk_intake_path(
                                             intake.id, filename: intake.consent_pdf_filename))
          expect(response.body).to include(zendesk_document_path(id_document.id))
          expect(response.body).to include(zendesk_document_path(w2_document.id))

          expect(response.body).to include(pdf_zendesk_intake_path(duplicate_intake.id, filename: duplicate_intake.intake_pdf_filename))
          expect(response.body).to include(consent_pdf_zendesk_intake_path(
                                             duplicate_intake.id, filename: duplicate_intake.consent_pdf_filename))
          expect(response.body).to include(zendesk_document_path(duplicate_id_document.id))
          expect(response.body).to include(zendesk_document_path(duplicate_w2_document.id))
        end
      end
    end
  end
end
