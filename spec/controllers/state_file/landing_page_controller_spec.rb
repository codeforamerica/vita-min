require 'rails_helper'

RSpec.describe StateFile::LandingPageController do
  StateFile::StateInformationService.active_state_codes.excluding(:ny).each do |state_code|
    describe "#update" do
      it_behaves_like :start_intake_concern, intake_class: StateFile::StateInformationService.intake_class(state_code) do
        let(:valid_params) do
          {
            us_state: state_code
          }
        end
      end
    end

    describe "#edit" do
      let(:intake) { create(StateFile::StateInformationService.intake_class(state_code).name.underscore.to_sym) }
      before do
        sign_in intake
      end

      it "does not set the current_step" do
        get :edit, params: { us_state: state_code }
        expect(response).to be_ok
        expect(StateFile::StateInformationService.intake_class(state_code).last.current_step).to be_nil
      end

      context "when it is after closing" do
        around do |example|
          Timecop.freeze(Rails.configuration.state_file_end_of_in_progress_intakes + 1.day) do
            example.run
          end
        end

        it "does not redirect them to the about page" do
          get :edit, params: { us_state: state_code }
          expect(response).not_to have_http_status(:redirect)
        end
      end
    end
  end
end