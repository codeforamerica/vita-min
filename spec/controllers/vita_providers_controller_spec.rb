require "rails_helper"

RSpec.describe VitaProvidersController do
  before do
    allow(subject).to receive(:send_mixpanel_event)
  end

  describe "#include_analytics?" do
    it "returns true" do
      expect(subject.include_analytics?).to eq true
    end
  end

  describe "#index" do
    context "get page with no params" do
      it "shows no search results" do
        get :index

        expect(assigns(:providers)).to eq []
      end

      it "returns an OK response" do
        get :index

        expect(response).to be_ok
      end

      it "does not have any errors" do
        get :index

        expect(assigns(:provider_search_form).errors.present?).to eq false
      end
    end

    context "search invalid zip" do
      let(:params) do
        { zip: "10928374" }
      end

      it "shows a validation error and no search results" do
        get :index, params: params

        expect(assigns(:providers)).to eq []
        expect(assigns(:provider_search_form).errors.messages[:zip]).to include "Please enter a valid 5-digit zip code."
      end

      it "sends provider_search_bad_zip event to mixpanel" do
        get :index, params: params

        expected_data = { zip: "10928374" }
        expect(subject).to have_received(:send_mixpanel_event).with(event_name: "provider_search_bad_zip", data: expected_data)
      end
    end

    context "search with valid zip" do
      let(:params) do
        { zip: "94609" }
      end

      context "with results" do
        let(:archived_providers) do
          create_list :vita_provider, 2, :with_coordinates, lat_lon: [37.834519, -122.263273], archived: true
        end
        let!(:local_providers) { create_list :vita_provider, 5, :with_coordinates, lat_lon: [37.834519, -122.263273] }

        it "returns the first page of providers, not including archived records" do
          get :index, params: params

          expect(assigns(:providers).size).to eq 5
          local_providers.each do |provider|
            expect(assigns(:providers)).to include provider
          end
        end

        it "sends provider_search event to mixpanel" do
          get :index, params: params

          expected_data = {
            zip: "94609",
            zip_name: "Oakland, California",
            result_count: "5",
            distance_to_closest_result: 0,
            page: "1",
          }
          expect(subject).to have_received(:send_mixpanel_event).with(event_name: "provider_search", data: expected_data)
        end
      end

      context "with no results" do
        render_views

        it "shows an apology message" do
          get :index, params: params

          expect(assigns(:providers)).to eq []
          expect(response.body).to have_text "We found no results within 50 miles of your address."
        end

        it "sends provider_search_no_results event to mixpanel" do
          get :index, params: params

          expected_data = {
            zip: "94609",
            zip_name: "Oakland, California",
          }
          expect(subject).to have_received(:send_mixpanel_event).with(event_name: "provider_search_no_results", data: expected_data)
        end
      end

      context "get second page" do
        let!(:closest_providers) { create_list :vita_provider, 5, :with_coordinates, lat_lon: [37.834519, -122.263273] }
        let!(:next_closest_providers) { create_list :vita_provider, 5, :with_coordinates, lat_lon: [37.826387, -122.269738] }
        let(:params) do
          { zip: "94609", page: 2 }
        end

        it "returns the second page of providers" do
          get :index, params: params

          expect(assigns(:providers).size).to eq 5
          next_closest_providers.each do |provider|
            expect(assigns(:providers)).to include provider
          end
        end

        it "sends provider_search event to mixpanel with page number" do
          get :index, params: params

          expected_data = {
            zip: "94609",
            zip_name: "Oakland, California",
            result_count: "10",
            distance_to_closest_result: 1,
            page: "2",
          }
          expect(subject).to have_received(:send_mixpanel_event).with(event_name: "provider_search", data: expected_data)
        end
      end

      context "with invalid page number" do
        let!(:closest_providers) { create_list :vita_provider, 5, :with_coordinates, lat_lon: [37.834519, -122.263273] }
        let!(:next_closest_providers) { create_list :vita_provider, 5, :with_coordinates, lat_lon: [37.826387, -122.269738] }
        let(:params) do
          { zip: "94609", page: "invalid" }
        end

        it "shows no search results" do
          get :index, params: params

          expect(assigns(:providers)).to eq([])
        end
      end
    end
  end

  describe "#show" do
    context "with a valid id" do
      let(:provider) { create :vita_provider, :with_coordinates, lat_lon: [37.834519, -122.263273] }

      context "with no zip in params" do
        it "returns 200 with the appropriate record" do
          get :show, params: { id: provider.id }

          expect(response).to be_ok
          expect(assigns(:provider)).to eq provider
        end

        it "sends provider_page_view event with no zip to mixpanel" do
          get :show, params: { id: provider.id }

          expected_data = {
            provider_id: provider.id.to_s,
            provider_name: "Public Library of the Test Suite",
          }
          expect(subject).to have_received(:send_mixpanel_event).with(event_name: "provider_page_view", data: expected_data)
        end
      end

      context "with an invalid zip in params" do
        it "sends provider_page_view event with no zip to mixpanel" do
          get :show, params: { id: provider.id, zip: "123456789" }

          expected_data = {
            provider_id: provider.id.to_s,
            provider_name: "Public Library of the Test Suite",
          }
          expect(subject).to have_received(:send_mixpanel_event).with(event_name: "provider_page_view", data: expected_data)
        end
      end

      context "with zip in params" do
        it "gets the searched zip from params and calculates distance" do
          get :show, params: { id: provider.id.to_s, zip: "94609" }

          expect(assigns(:zip)).to eq "94609"
          expect(assigns(:distance)).to eq 179.95539713817547
        end

        it "sends provider_page_view event to mixpanel" do
          get :show, params: { id: provider.id.to_s, zip: "94609", page: "2" }

          expected_data = {
            provider_id: provider.id.to_s,
            provider_name: "Public Library of the Test Suite",
            provider_distance_to_searched_zip: 0,
            provider_searched_zip: "94609",
            provider_searched_zip_name: "Oakland, California",
            provider_search_result_page: "2",
          }
          expect(subject).to have_received(:send_mixpanel_event).with(event_name: "provider_page_view", data: expected_data)
        end
      end
    end
  end

  describe "#map" do
    let(:provider) { create :vita_provider, :with_coordinates }

    it "redirects to the provider's google maps url" do
      get :map, params: { id: provider.id }

      expect(response).to redirect_to provider.google_maps_url
    end

    it "sends provider_page_map_click event to mixpanel" do
      get :map, params: { id: provider.id }

      expected_data = {
        provider_id: provider.id.to_s,
        provider_name: "Public Library of the Test Suite",
      }
      expect(subject).to have_received(:send_mixpanel_event).with(event_name: "provider_page_map_click", data: expected_data)
    end
  end
end
