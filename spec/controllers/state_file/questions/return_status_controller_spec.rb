require "rails_helper"

RSpec.describe StateFile::ReturnStatusController, type: :controller do
  #TODO : set up the intake

  context "when it is after closing" do
    around do |example|
      Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes + 1.day) do
        example.run
      end
    end
    it "does not redirect them to the about page" do
      get :edit, params: { us_state: :ny }
      expect(response).not_to have_http_status(:redirect)
    end
  end

end