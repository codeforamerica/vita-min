require "rails_helper"

RSpec.describe Questions::ChatWithUsController do
  render_views

  describe "#edit" do
    VitaPartner.all.each do |vita_partner|
      it "renders the page with no error finding the partner logo for #{vita_partner.name}" do
        intake = create :intake, vita_partner: vita_partner
        allow(subject).to receive(:current_intake).and_return(intake)

        expect { get :edit }.not_to raise_error
      end
    end
  end
end