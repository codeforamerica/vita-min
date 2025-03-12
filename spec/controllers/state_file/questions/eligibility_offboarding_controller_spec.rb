require 'rails_helper'

RSpec.describe StateFile::Questions::EligibilityOffboardingController do
  describe ".show?" do
    context "when the intake has a disqualifying answer" do
      it "returns true" do
        intake = double("intake", has_disqualifying_eligibility_answer?: true)
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when the intake does not have a disqualifying answer" do
      it "returns false" do
        intake = double("intake", has_disqualifying_eligibility_answer?: false)
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    before do
      sign_in intake
    end

    context "NJ specific content" do
      # az does not utilize eligiblity_offboarding_controller in its flow
      StateFile::StateInformationService.active_state_codes.excluding("az", "ny", "nj").each do |state_code|
        render_views

        let(:intake) { create "state_file_#{state_code}_intake".to_sym }

        it "#{state_code} does not show NJ-specific content" do
          get :edit
          expect(response.body).to include("Visit our FAQ")
          expect(response.body).not_to include("Get connected now")
        end
      end
    end

    # For NJ, two controllers can lead to the ineligible offboarding controller -- so we still have an issue where if the
    # locale changes, session[:offboarded_from] will be `nil` and they will have an inactive Go back button.
    [
      ["id", StateFile::Questions::IdEligibilityResidenceController],
      ["md", StateFile::Questions::MdEligibilityFilingStatusController],
      ["nc", StateFile::Questions::NcEligibilityController],
      ["nj", StateFile::Questions::NjEligibilityHealthInsuranceController],
      ["nj", StateFile::Questions::NjRetirementWarningController, StateFile::Questions::NjEligibilityHealthInsuranceController]
    ].each do |state_code, eligibility_controller, default_eligibility_controller|
      context "#{state_code} with eligibility controller #{eligibility_controller}" do
        render_views

        let(:intake) { create "state_file_#{state_code}_intake".to_sym }
        let(:eligibility_controller_path) { eligibility_controller.to_path_helper }

        context "with offboarded_from set in the session" do
          before do
            session[:offboarded_from] = eligibility_controller_path
          end

          it "uses the correct prev_path for the Go back button" do
            get :edit

            expect(Nokogiri::HTML.parse(response.body)).to have_link(href: eligibility_controller_path)
          end
        end

        context "without offboarded_from set in the session" do
          let(:default_controller_path) { default_eligibility_controller ? default_eligibility_controller.to_path_helper : eligibility_controller_path }

          it "uses the default prev_path for the Go back button (controller right before offboarding controller in flow)" do
            get :edit

            expect(Nokogiri::HTML.parse(response.body)).to have_link(href: default_controller_path)
          end
        end
      end
    end

    context "NJ" do
      render_views
      let(:intake) { create :state_file_nj_intake }
  
      it "shows NJ-specific content" do
        get :edit
        expect(response.body).to include("Visit our FAQ")
        expect(response.body).to include("Get connected now")
      end
    end
  end
end
