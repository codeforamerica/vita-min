require "rails_helper"

RSpec.describe IntakeSiteDropOffsController do
  let(:ticket_id) { '23' }

  before do
    allow(MixpanelService).to receive(:send_event)
  end

  describe "#new" do
    let(:org) { "thc" }

    before do
      get :new, params: { organization: org }
    end

    context "with an intake site stored in the session" do
      let(:intake_site) { "Denver Housing Authority - Westwood" }
      before { session[:intake_site] = intake_site}

      it "sets a default intake site for the drop off" do
        get :new, params: { organization: org }
        expect(assigns(:drop_off).intake_site).to eq intake_site
      end
    end

    context "for United Way of Central Ohio" do
      let(:org) { "uwco" }

      it "sets the default state to Ohio" do
        expect(assigns(:drop_off).state).to eq "OH"
      end
    end

    context "for Tax Help Colorado" do
      let(:org) { "thc" }

      it "sets the default state to Colorado" do
        expect(assigns(:drop_off).state).to eq "CO"
      end
    end

    context "for Goodwilll Southern Rivers" do
      let(:org) { "gwisr" }

      it "sets the default state to Georgia" do
        expect(assigns(:drop_off).state).to eq "GA"
      end
    end

    context "for United Way Bay Area" do
      let(:org) { "uwba" }

      it "sets the default state to California" do
        expect(assigns(:drop_off).state).to eq "CA"
      end
    end

    context "for Foundation Communities" do
      let(:org) { "fc" }

      it "sets the default state to Texas" do
        expect(assigns(:drop_off).state).to eq "TX"
      end
    end

    context "for United Way of Greater Richmond and Petersburg" do
      let(:org) { "uwvp" }

      it "sets the default state to Virginia" do
        expect(assigns(:drop_off).state).to eq "VA"
      end
    end
  end

  describe "#show" do
    it "finds the right IntakeSiteDropOff record" do
      drop_off = create :intake_site_drop_off
      get :show, params: { organization: "thc", id: drop_off.id }

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
            organization: "thc",
            intake_site_drop_off: {
              name: "Cassie Cantaloupe",
              email: "ccherry6@example.com",
              phone_number: "4158161286",
              intake_site: "Trinidad State Junior College - Alamosa",
              state: "CO",
              signature_method: "in_person",
              pickup_date_string: "2/6",
              certification_level: "Advanced",
              hsa: "1",
              additional_info: "Needs to double check if they have another W-2",
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
          expect(drop_off.organization).to eq "thc"
          expect(drop_off.email).to eq "ccherry6@example.com"
          expect(drop_off.phone_number).to eq "14158161286"
          expect(drop_off.intake_site).to eq "Trinidad State Junior College - Alamosa"
          expect(drop_off.state).to eq "CO"
          expect(drop_off.signature_method).to eq "in_person"
          expect(drop_off.pickup_date).to eq Date.new(2020, 2, 6)
          expect(drop_off.certification_level).to eq "Advanced"
          expect(drop_off.hsa).to eq true
          expect(drop_off.additional_info).to eq "Needs to double check if they have another W-2"
          expect(drop_off.timezone).to eq "America/Juneau"

          expect(response).to redirect_to show_drop_off_path(id: drop_off.id, organization: "thc")
        end

        context "when there is no matching prior drop off" do
          it "creates a new drop off and redirects to the show page" do
            post :create, params: valid_params

            drop_off = IntakeSiteDropOff.last

            expect(response).to redirect_to show_drop_off_path(id: drop_off.id, organization: "thc")
          end

          it "sends a create_drop_off event to mixpanel" do
            post :create, params: valid_params

            expected_data = {
              organization: "thc",
              intake_site: "Trinidad State Junior College - Alamosa",
              state: "CO",
              signature_method: "in_person",
              certification_level: "Advanced",
              hsa: true,
            }
            expect(MixpanelService).to have_received(:send_event).with(hash_including(
                                                                           event_name: "create_drop_off",
                                                                           data: expected_data))
          end

          it "sets the intake site in the session" do
            post :create, params: valid_params

            expect(session[:intake_site]).to eq "Trinidad State Junior College - Alamosa"
          end
        end

        context "when there is a matching old drop off" do
          let!(:prior_drop_off) do
            create(
              :intake_site_drop_off,
              name: "Cassie Cantaloupe",
              phone_number: "4158161286",
              zendesk_ticket_id: "151"
            )
          end

          it "appends to an existing ticket" do
            post :create, params: valid_params

            drop_off = IntakeSiteDropOff.last

            expect(drop_off.zendesk_ticket_id).to eq prior_drop_off.zendesk_ticket_id
          end

          it "sends a append_to_drop_off event to mixpanel" do
            post :create, params: valid_params

            expected_data = {
              organization: "thc",
              intake_site: "Trinidad State Junior College - Alamosa",
              state: "CO",
              signature_method: "in_person",
              certification_level: "Advanced",
              hsa: true,
            }
            expect(MixpanelService).to have_received(:send_event).with(hash_including(event_name: "append_to_drop_off", data: expected_data))
          end
        end

        context "when there is a matching old drop off with no zendesk ticket id" do
          let!(:prior_drop_off) do
            create(
              :intake_site_drop_off,
              name: "Cassie Cantaloupe",
              phone_number: "4158161286",
              zendesk_ticket_id: nil
            )
          end

          it "creates a new drop off" do
            post :create, params: valid_params

            drop_off = IntakeSiteDropOff.last

            expect(response).to redirect_to show_drop_off_path(id: drop_off.id, organization: "thc")
          end

          it "sends a create_drop_off event to mixpanel" do
            post :create, params: valid_params

            expected_data = {
              organization: "thc",
              intake_site: "Trinidad State Junior College - Alamosa",
              state: "CO",
              signature_method: "in_person",
              certification_level: "Advanced",
              hsa: true,
            }
            expect(MixpanelService).to have_received(:send_event).with(hash_including(event_name: "create_drop_off", data: expected_data))
          end
        end
      end

      context "with invalid params" do
        let(:invalid_params) do
          {
            organization: "thc",
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
          expect(assigns(:drop_off).errors).to include(:phone_number)
          expect(response).to render_template(:new)
        end

        it "tracks the validation errors in mixpanel" do
          post :create, params: invalid_params

          expected_data = {
            organization: "thc",
            intake_site: "Denver Main Library",
            state: nil,
            invalid_signature_method: true,
            invalid_phone_number: true,
            invalid_intake_site: true,
            invalid_state: true,
            hsa: false,
            certification_level: nil,
            signature_method: "pony express"
          }
          expect(MixpanelService).to have_received(:send_event).with(hash_including(event_name: "validation_error", data: expected_data))
        end
      end
    end
  end
end
