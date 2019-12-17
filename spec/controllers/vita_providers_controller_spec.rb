require "rails_helper"

RSpec.describe VitaProvidersController do
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
        { provider_search_form: { zip: "10928374"} }
      end

      it "shows a validation error and no search results" do
        get :index, params: params

        expect(assigns(:providers)).to eq []
        expect(assigns(:provider_search_form).errors.messages[:zip]).to include "Please enter a valid 5 digit zip code."
      end
    end

    context "search with valid zip" do
      let(:params) do
        { provider_search_form: { zip: "94609" } }
      end

      context "with results" do
        let!(:local_providers) { create_list :vita_provider, 5, :with_coordinates, lat_lon: [37.834519, -122.263273] }

        it "returns the first page of providers" do
          get :index, params: params

          expect(assigns(:providers).size).to eq 5
          local_providers.each do |provider|
            expect(assigns(:providers)).to include provider
          end
        end
      end

      context "with no results" do
        render_views

        it "shows an apology message" do
          get :index, params: params

          expect(assigns(:providers)).to eq []
          expect(response.body).to have_text "We found no results within 50 miles of your address."
        end
      end

      context "get second page" do
        let!(:closest_providers) { create_list :vita_provider, 5, :with_coordinates, lat_lon: [37.834519, -122.263273] }
        let!(:next_closest_providers) { create_list :vita_provider, 5, :with_coordinates, lat_lon: [37.826387, -122.269738] }
        let(:params) do
          { provider_search_form: { zip: "94609", page: 2 } }
        end

        it "returns the second page of providers" do
          get :index, params: params

          expect(assigns(:providers).size).to eq 5
          next_closest_providers.each do |provider|
            expect(assigns(:providers)).to include provider
          end
        end
      end
    end
  end

  describe "#show" do
    context "with a valid id" do
      let(:provider) { create :vita_provider, :with_coordinates, lat_lon: [37.834519, -122.263273] }
      it "returns 200 with the appropriate record" do
        get :show, params: { id: provider.id }

        expect(response).to be_ok
        expect(assigns(:provider)).to eq provider
      end

      it "gets the searched zip from params and calculates distance" do
        get :show, params: { id: provider.id, zip: "94609" }

        expect(assigns(:zip)).to eq "94609"
        expect(assigns(:distance)).to eq 0.1
      end
    end
  end
end
