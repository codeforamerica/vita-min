require "rails_helper"

shared_examples :df_data_required do |required, state_code|
  let(:intake) { create(StateFile::StateInformationService.intake_class(state_code).name.underscore.to_sym) }

  context "when there is no df data" do
    before do
      intake.update(raw_direct_file_data: nil)
    end

    if required
      it "redirects to login" do
        get :edit

        expect(response).to redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
      end
    else
      it "allows them through" do
        get :edit

        expect(response).to render_template :edit
      end
    end
  end

  context "when there is df data" do
    it "allows them through" do
      get :edit

      expect(response).to render_template :edit
    end
  end
end