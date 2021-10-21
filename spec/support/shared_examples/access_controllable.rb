# Usage:
#
#   it_behaves_like :a_get_action_for_authenticated_users_only, action: :new
#
#   # set params for this spec
#   it_behaves_like :a_get_action_for_authenticated_users_only, action: :new do
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
#   it_behaves_like :a_get_action_for_authenticated_users_only, action: :new
#
shared_examples :a_get_action_for_authenticated_users_only do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "with an anonymous user" do
    it "saves the current path to the session and redirects to the login path" do
      get action, params: params

      expect(response).to redirect_to new_user_session_path
      expect(session[:after_login_path]).to be_present
    end
  end
end

shared_examples :a_post_action_for_authenticated_users_only do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "with an anonymous user" do
    it "saves the current path to the session and redirects to the login path" do
      post action, params: params

      expect(response).to redirect_to new_user_session_path
      expect(session[:after_login_path]).to be_present
    end
  end
end

shared_examples :a_get_action_for_admins_only do |action:|
  it_behaves_like :an_action_for_admins_only, action: action, method: :get
end

shared_examples :a_post_action_for_admins_only do |action:|
  it_behaves_like :an_action_for_admins_only, action: action, method: :post
end

shared_examples :an_action_for_admins_only do |action:, method:|
  let(:params) { {} } unless method_defined?(:params)

  context "with a non-admin user" do
    before { sign_in( create :user ) }

    it "returns 403 Forbidden" do
      send(method, action, params: params)

      expect(response.status).to eq 403
    end
  end
end