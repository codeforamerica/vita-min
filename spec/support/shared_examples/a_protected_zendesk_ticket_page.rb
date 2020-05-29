shared_examples :a_protected_zendesk_ticket_page do |action: :show|
  context "as an anonymous user" do
    it "stores the current path in the session and redirects to the zendesk sign in page" do
      get action, params: valid_params

      expect(response).to redirect_to zendesk_sign_in_path
      expect(session[:after_login_path]).to be_present
    end
  end

  context "as an authenticated zendesk user" do
    let(:user) { build :user, provider: "zendesk", id: 1 }

    before do
      allow(subject).to receive(:current_user).and_return user
    end

    context "tracking zendesk user page views" do
      render_views
      before { allow(subject).to receive(:current_ticket) }

      it "adds the current_user to the payload request details" do
        expect(Rails.logger).to receive(:info).with(/\"current_user_id\":#{user.id}/)
        get action, params: valid_params
      end
    end

    context "without access to the current ticket" do
      before { allow(subject).to receive(:current_ticket).and_return(nil) }

      it "returns 404 with a not found page" do
        get action, params: valid_params

        expect(response.status).to eq 404
        expect(response).to render_template "public_pages/page_not_found"
      end
    end

    context "with access to the current ticket" do
      let(:ticket) { instance_double(ZendeskAPI::Ticket) }
      before { allow(subject).to receive(:current_ticket).and_return(ticket) }

      it "returns 200 OK" do
        get action, params: valid_params

        expect(response).to be_ok
      end
    end
  end
end
