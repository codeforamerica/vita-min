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

shared_examples :a_post_action_for_authenticated_clients_only do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "with an anonymous client" do
    it "redirects to the login path" do
      post action, params: params

      expect(response).to redirect_to new_portal_client_login_path
    end
  end
end