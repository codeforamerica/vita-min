require 'rails_helper'

RSpec.describe Questions::WelcomeSpouseController, type: :controller do
  describe ".show?" do
    let(:intake) { create :intake }
    let!(:user) { create :user, intake: intake }

    context "when the intake has two users" do
      let!(:spouse_user) { create :spouse_user, intake: intake }

      it "returns true" do
        expect(Questions::WelcomeSpouseController.show?(intake)).to eq true
      end
    end

    context "when the intake has one user" do
      it "returns false" do
        expect(Questions::WelcomeSpouseController.show?(intake)).to eq false
      end
    end
  end
end
