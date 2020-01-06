require "rails_helper"

RSpec.describe IntakeSiteDropOffsController do
  let(:ticket_id) { '23' }
  let(:zendesk_drop_off_service_spy) do
    instance_double(ZendeskDropOffService, create_ticket: ticket_id, append_to_existing_ticket: true)
  end

  before do
    allow(ZendeskDropOffService).to receive(:new).and_return(zendesk_drop_off_service_spy)
  end

  describe "#show" do
    it "finds the right IntakeSiteDropOff record" do
      drop_off = create :intake_site_drop_off
      get :show, params: { id: drop_off.id }

      expect(response.status).to eq 200
      expect(response).to render_template(:show)
      expect(assigns(:drop_off)).to eq drop_off
    end
  end

  describe "#create" do
    context "when a volunteer at an intake site creates a new drop-off" do
      context "with valid params" do
        let(:valid_params) do
          {
            intake_site_drop_off: {
              name: "Cassie Cantaloupe",
              email: "ccherry6@example.com",
              phone_number: "4158161286",
              intake_site: "Trinidad State Junior College - Alamosa",
              signature_method: "in_person",
              pickup_date_string: "2/6",
              certification_level: "Advanced",
              hsa: "1",
              additional_info: "Needs to double check if they have another W-2",
              document_bundle: fixture_file_upload("attachments/document_bundle.pdf"),
              timezone: "America/Juneau",
            }
          }
        end

        it "saves all the info and redirects to a show page for the created record" do
          expect {
            post :create, params: valid_params
          }.to change(IntakeSiteDropOff, :count).by(1)

          drop_off = IntakeSiteDropOff.last

          expect(drop_off.name).to eq "Cassie Cantaloupe"
          expect(drop_off.email).to eq "ccherry6@example.com"
          expect(drop_off.phone_number).to eq "14158161286"
          expect(drop_off.intake_site).to eq "Trinidad State Junior College - Alamosa"
          expect(drop_off.signature_method).to eq "in_person"
          expect(drop_off.pickup_date).to eq Date.new(2020, 2, 6)
          expect(drop_off.certification_level).to eq "Advanced"
          expect(drop_off.hsa).to eq true
          expect(drop_off.additional_info).to eq "Needs to double check if they have another W-2"
          expect(drop_off.document_bundle).to be_attached
          expect(drop_off.timezone).to eq "America/Juneau"

          expect(response).to redirect_to intake_site_drop_off_path(id: drop_off.id)
        end

        context "when there is no matching prior drop off" do
          it "creates a ticket in Zendesk" do
            post :create, params: valid_params

            drop_off = IntakeSiteDropOff.last

            expect(ZendeskDropOffService).to have_received(:new).with(drop_off)
            expect(zendesk_drop_off_service_spy).to have_received(:create_ticket)
            expect(drop_off.zendesk_ticket_id).to eq ticket_id
            expect(response).to redirect_to intake_site_drop_off_path(id: drop_off.id)
          end
        end

        context "when there is a matching old drop off" do
          it "appends to an existing ticket" do
            prior_drop_off = create(
              :intake_site_drop_off,
              name: "Cassie Cantaloupe",
              phone_number: "4158161286",
              zendesk_ticket_id: "151"
            )

            post :create, params: valid_params

            drop_off = IntakeSiteDropOff.last

            expect(ZendeskDropOffService).to have_received(:new).with(drop_off)
            expect(zendesk_drop_off_service_spy).to have_received(:append_to_existing_ticket)
            expect(drop_off.zendesk_ticket_id).to eq prior_drop_off.zendesk_ticket_id
          end
        end
      end

      context "with invalid params" do
        let(:invalid_params) do
          {
            intake_site_drop_off: {
              name: "Gary Guava",
              email: "gguava@example.com",
              phone_number: "5551234567",
              intake_site: "Denver Main Library",
              signature_method: "pony express",
              additional_info: "Needs to double check if they have another W-2",
            }
          }
        end

        it "returns new without saving if the params are invalid" do
          expect {
            post :create, params: invalid_params
          }.not_to change(IntakeSiteDropOff, :count)

          expect(assigns(:drop_off)).not_to be_valid
          expect(assigns(:drop_off).errors).to include(:document_bundle)
          expect(response).to render_template(:new)
        end
      end
    end
  end
end
