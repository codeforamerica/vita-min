require "rails_helper"

RSpec.describe Questions::IdentityController do
  render_views

  describe "#edit" do
    context "with a next_path param in the URL" do
      let(:params) { { after_login: "/foo-bar" } }

      it "links to the omniauth callback with that URL" do
        get :edit, params: params
        
        expect(response.body).to include(idme_sign_in_path(after_login: "/foo-bar"))
      end
    end
  end
end
