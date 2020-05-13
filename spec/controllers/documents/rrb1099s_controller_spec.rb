require "rails_helper"

RSpec.describe Documents::Rrb1099sController do
  let(:attributes) { {} }
  let(:intake) { create :intake, intake_ticket_id: 1234, **attributes }

  describe ".show?" do
    context "when they had social security income" do
      let(:attributes) { { had_social_security_income: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        { had_social_security_income: "no" }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

