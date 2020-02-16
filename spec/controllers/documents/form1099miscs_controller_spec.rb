require "rails_helper"

RSpec.describe Documents::Form1099miscsController do
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }

  describe ".show?" do
    context "when they had self employment income" do
      let(:attributes) { { had_self_employment_income: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "when they had one or more jobs" do
      let(:attributes) { { job_count: 1 } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        {
          job_count: 0,
          had_self_employment_income: "no",
        }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

