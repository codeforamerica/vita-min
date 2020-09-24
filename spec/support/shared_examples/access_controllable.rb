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
    it "saves the current path to the session and redirects to the zendesk login path" do
      get action, params: params

      expect(response).to redirect_to zendesk_sign_in_path
      expect(session[:after_login_path]).to be_present
    end
  end
end

shared_examples :a_post_action_for_authenticated_users_only do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "with an anonymous user" do
    it "saves the current path to the session and redirects to the zendesk login path" do
      post action, params: params

      expect(response).to redirect_to zendesk_sign_in_path
      expect(session[:after_login_path]).to be_present
    end
  end
end

shared_examples :a_get_action_for_admins_only do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "with a non-admin user" do
    before { sign_in( create :agent_user ) }

    it "saves the current path to the session and redirects to the zendesk login path" do
      get action, params: params

      expect(response.status).to eq 403
    end
  end
end

shared_examples :a_post_action_for_admins_only do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "with a non-admin user" do
    before { sign_in( create :agent_user ) }

    it "saves the current path to the session and redirects to the zendesk login path" do
      post action, params: params

      expect(response.status).to eq 403
    end
  end
end

shared_examples :a_get_action_for_beta_testers_only do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "with a non-admin user" do
    before { sign_in( create :user, is_beta_tester: false ) }

    it "responds with status forbidden" do
      get action, params: params

      expect(response.status).to eq 403
    end
  end
end

shared_examples :a_post_action_for_beta_testers_only do |action:|
  let(:params) { {} } unless method_defined?(:params)

  context "with a non-admin user" do
    before { sign_in( create :user, is_beta_tester: false ) }

    it "responds with status forbidden" do
      post action, params: params

      expect(response.status).to eq 403
    end
  end
end