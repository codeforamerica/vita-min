require "rails_helper"

describe "GYR Questions Controllers minimal tests", type: :controller do
  Navigation::GyrQuestionNavigation.controllers.each do |controller|
    next if [Questions::WelcomeController,
             Questions::DependentsController].include? controller
    describe controller do
      render_views

      let(:vita_partner) { create :organization }
      let(:intake) {
        create :intake,
               sms_phone_number: "+18324658840",
               email_address: "test@test.com",
               primary_ssn: "123456789",
               vita_partner: vita_partner
      }
      before do
        sign_in intake.client
      end

      it 'succeeds' do
        if controller == Questions::AtCapacityController
          intake.client.update(routing_method: "at_capacity")
        elsif controller == Questions::ReturningClientController
          sign_out intake.client
          session[:intake_id] = intake.id
        end

        get :edit
        expect(response).to be_successful
      end
    end
  end
end