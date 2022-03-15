require "rails_helper"

describe DependentFlowService do
  let(:controller_name) { "Ctc::Questions::Dependents::InfoController" }
  let(:dependent) { create :qualifying_child }
  subject { described_class.new(dependent, TaxReturn.current_tax_year, controller_name) }

  describe ".show?" do
    context "when dependent is nil" do
      let(:dependent) { nil }
      it "returns false" do
        expect(subject.show?).to eq false
      end
    end

    context "when controller name is not recognized by handler" do
      let(:controller_name) { "Ctc::Questions::Dependents::NewController" }
      it "raises an error" do
        expect {
          subject.show?
        }.to raise_error RuntimeError
      end
    end
  end
end