require "rails_helper"

shared_examples :df_data_required do |required, state_code, record_type|
  let(:intake) { create(StateFile::StateInformationService.intake_class(state_code).name.underscore.to_sym) }
  if record_type
    let!(:record) { create(record_type, intake: intake) }
    let(:params) { { id: record.id } }
  else
    let(:params) { {} }
  end

  before do
    sign_in intake
  end

  context "#{state_code}: when there is no df data" do
    before do
      intake.update(df_data_import_succeeded_at: nil)
    end

    if required
      it "redirects to login on edit" do
        get :edit, params: params

        expect(response).to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
      end

      it "redirects to login on update" do
        post :update, params: params

        expect(response).to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
      end
    else
      it "does not redirect to login on edit" do
        get :edit, params: params

        expect(response).not_to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
      end

      it "does not redirect to login on update" do
        post :update, params: params

        expect(response).not_to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
      end
    end
  end

  context "#{state_code}: when there is df data" do
    it "does not redirect to login on edit" do
      get :edit, params: params

      expect(response).not_to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
    end

    it "does not redirect to login on update" do
      post :update, params: params

      expect(response).not_to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
    end
  end
end