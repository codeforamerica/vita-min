# Usage:
#
#   it_behaves_like :a_get_action_for_authenticated_clients_only, action: :new
#
#   # set params for this spec
#   it_behaves_like :a_get_action_for_authenticated_clients_only, action: :new do
#     let(:params) do
#       { my_mode: { name: "some name" } }
#     end
#   end
#
#   # set values for this & other specs
#   let(:params) do
#     { my_mode: { name: "some name" } }
#   end
#
#   it_behaves_like :a_get_action_for_authenticated_clients_only, action: :new
#
shared_examples :a_get_action_for_authenticated_clients_only do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "with an anonymous client" do
    it "redirects to the login path" do
      get action, params: params

      expect(response).to redirect_to new_portal_client_login_path
    end
  end
end

shared_examples :a_get_action_redirects_for_show_still_needs_help_clients do |action:|
  let(:params) { {} } unless method_defined?(:params)
  let(:client) { create(:intake).client } unless method_defined?(:client)

  context "with an show needs help client" do
    before do
      sign_in client
      allow(StillNeedsHelpService).to receive(:must_show_still_needs_help_flow?).with(client).and_return(true)
    end

    it "redirects to the still needs help flow" do
      get action, params: params

      expect(response).to redirect_to portal_still_needs_helps_path
    end
  end

  context "with a client that does not need to see the needs help flow" do
    let(:client) { create(:intake).client } unless method_defined?(:client)

    before do
      sign_in client
      allow(StillNeedsHelpService).to receive(:must_show_still_needs_help_flow?).with(client).and_return(false)
    end

    it "does not redirect to the still needs help flow" do
      get action, params: params

      expect(response).not_to redirect_to portal_still_needs_helps_path
    end
  end
end

shared_examples :a_post_action_for_authenticated_clients_only do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "with an anonymous client" do
    it "redirects to the login path" do
      post action, params: params

      expect(response).to redirect_to new_portal_client_login_path
    end
  end
end
