require "rails_helper"

RSpec.describe Zendesk::TicketsController do
  let(:ticket_id) { 123 }
  let(:user) { create :user, provider: "zendesk" }
  let(:ticket) { double("ZendeskAPI::Ticket", id: ticket_id, subject: "Oswald Orange") }

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

      context "with intakes" do
        let!(:intake) { create :intake, intake_ticket_id: ticket_id, zendesk_instance_domain: "eitc" }
        let!(:id_document) { create :document, :with_upload, intake: intake, document_type: "ID" }
        let!(:w2_document) { create :document, :with_upload, intake: intake, document_type: "W-2" }

        context "with one intake" do
          it "shows all documents for the intake based on ticket id" do
            get :show, params: { id: ticket_id }

            expect(assigns(:ticket)).to eq ticket
            expect(assigns(:intakes)).to contain_exactly(intake)
            expect(assigns(:document_groups).values.map(&:first).map(&:original_object))
              .to contain_exactly(id_document, w2_document)
            expect(response.body).to include(pdf_zendesk_intake_path(id: intake.id, filename: intake.intake_pdf_filename))
            expect(response.body).to include(consent_pdf_zendesk_intake_path(
                                               id: intake.id, filename: intake.consent_pdf_filename))
            expect(response.body).to include(zendesk_document_path(id: id_document.id))
            expect(response.body).to include(zendesk_document_path(id: w2_document.id))
          end
        end

        context "with duplicate linked intakes" do
          let!(:duplicate_intake) { create :intake, intake_ticket_id: ticket_id, zendesk_instance_domain: "eitc" }
          let!(:duplicate_id_document) { create :document, :with_upload, intake: intake, document_type: "ID" }
          let!(:duplicate_w2_document) { create :document, :with_upload, intake: intake, document_type: "W-2" }

          it "shows all documents for all intakes with that ticket id" do
            get :show, params: { id: ticket_id }

            expect(assigns(:ticket)).to eq ticket
            expect(assigns(:intakes)).to contain_exactly(intake, duplicate_intake)
            contain_exactly(id_document, duplicate_id_document, w2_document, duplicate_w2_document)

            expect(response.body).to include(pdf_zendesk_intake_path(id: intake.id, filename: intake.intake_pdf_filename))
            expect(response.body).to include(consent_pdf_zendesk_intake_path(
                                               id: intake.id, filename: intake.consent_pdf_filename))
            expect(response.body).to include(zendesk_document_path(id: id_document.id))
            expect(response.body).to include(zendesk_document_path(id: w2_document.id))

            expect(response.body).to include(pdf_zendesk_intake_path(id: duplicate_intake.id, filename: duplicate_intake.intake_pdf_filename))
            expect(response.body).to include(consent_pdf_zendesk_intake_path(
                                               id: duplicate_intake.id, filename: duplicate_intake.consent_pdf_filename))
            expect(response.body).to include(zendesk_document_path(id: duplicate_id_document.id))
            expect(response.body).to include(zendesk_document_path(id: duplicate_w2_document.id))
          end

          context "with a UnitedWayTucson intake that coincidentally has the same ticket id" do
            let!(:coincidental_uwtsa_intake) { create :intake, intake_ticket_id: ticket_id, zendesk_instance_domain: "unitedwaytucson" }

            it "does not include information from the UWTSA intake" do
              get :show, params: { id: ticket_id }


              expect(assigns(:intakes)).not_to include(coincidental_uwtsa_intake)
              expect(response.body).not_to include(
                 pdf_zendesk_intake_path(
                   id: coincidental_uwtsa_intake.id,
                   filename: coincidental_uwtsa_intake.intake_pdf_filename
                 )
               )
            end
          end
        end
      end

      context "with drop offs" do
        let!(:drop_off) { create :intake_site_drop_off, zendesk_ticket_id: ticket_id, created_at: 3.days.ago }

        context "with one drop off" do
          it "shows document bundle for drop off based on ticket id" do
            get :show, params: { id: ticket_id }

            expect(assigns(:ticket)).to eq ticket
            expect(assigns(:drop_offs)).to contain_exactly(drop_off)
            expect(response.body).to include("Document Bundle")
            expect(response.body).to include(zendesk_drop_off_path(id: drop_off.id))
            expect(response.body).to include("document_bundle.pdf")
            expect(response.body).to include("3 days ago")
          end
        end

        context "with multiple drop offs" do
          let!(:second_drop_off) { create :intake_site_drop_off, zendesk_ticket_id: ticket_id }

          it "shows both document bundles based on ticket id" do
            get :show, params: { id: ticket_id }

            expect(assigns(:ticket)).to eq ticket
            expect(assigns(:drop_offs)).to contain_exactly(drop_off, second_drop_off)
            expect(response.body).to include(zendesk_drop_off_path(id: drop_off.id))
            expect(response.body).to include(zendesk_drop_off_path(id: second_drop_off.id))
          end
        end
      end
    end
  end
end
