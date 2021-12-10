require "rails_helper"

RSpec.describe Hub::OrganizationForm do
  describe "#save" do
    subject { described_class.new(organization, params) }
    let(:organization) { build(:organization, coalition: coalition) }
    let(:params) { { } }
    let(:coalition) { nil }

    describe "#independent_org" do
      context "with an unpersisted org" do
        it "returns false" do
          expect(subject.is_independent).to be_falsey
        end

        context "when is_independent is true in the params" do
          let(:params) { { is_independent: true } }

          it "returns true" do
            expect(subject.is_independent).to be_falsey
          end
        end
      end

      context "with a persisted org" do
        before do
          organization.save!
        end

        context "when it is part of a coalition" do
          let(:coalition) { build(:coalition) }

          it "returns false" do
            expect(subject.is_independent).to be_falsey
          end
        end

        context "when it is not part of a coalition" do
          it "returns true" do
            expect(subject.is_independent).to be_truthy
          end
        end
      end
    end

    context "with a new organization" do
    end

    context "when creating an organization" do
    end

    context "when updating an organization" do
    end
  end
end
