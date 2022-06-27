require "rails_helper"

RSpec.describe CtcController do
  controller do
    def index
      head :ok
    end
  end

  describe "#set_get_started_link" do
    context "locale is en" do
      it "generates a link to the beginning of the GYR flow" do
        get :index

        expect(assigns(:get_started_link)).to eq "/en/questions/overview"
      end
    end

    context "locale is es" do
      it "generates a link to the beginning of the GYR flow" do
        get :index, params: { locale: 'es' }

        expect(assigns(:get_started_link)).to eq "/es/questions/overview"
      end
    end
  end
end
