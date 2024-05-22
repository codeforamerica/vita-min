require "rails_helper"

RSpec.feature "Web Intake Client matches with partner who is at capacity", :flow_explorer_screenshot do

  context "when there are no partners with capacity" do
    before do
      routing_service_double = instance_double(PartnerRoutingService)
      
      allow(routing_service_double).to receive(:routing_method).and_return :at_capacity
      allow(routing_service_double).to receive(:determine_partner).and_return nil
      allow(PartnerRoutingService).to receive(:new).and_return routing_service_double
      visit personal_info_questions_path
      fill_out_personal_information(name: "Gary", zip_code: "19143", birth_date: Date.parse("1983-10-12"), phone_number: "555-555-1212")
    end

    it "shows an at capacity page and logs the client out" do
      expect(page).to have_selector("h1", text: I18n.t("views.questions.at_capacity.title"))
      expect(page).to have_text I18n.t("views.questions.at_capacity.body")[1]
      expect(page).not_to have_text("Logout")
      expect(Intake.last.viewed_at_capacity).to be_truthy
    end
  end
end
