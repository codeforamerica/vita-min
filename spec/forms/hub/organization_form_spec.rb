require "rails_helper"

RSpec.describe Hub::OrganizationForm do
  describe "#save" do
    subject { described_class.new(organization, params) }

    let(:organization) { build(:organization, coalition: coalition) }
    let(:params) { {} }
    let(:coalition) { nil }

    describe "#independent_org" do
      context "with an unpersisted org" do
        context "when params do not specify is_independent" do
          it "returns false" do
            expect(subject.is_independent).to be_falsey
          end
        end

        context "when params specify is_independent is true" do
          let(:params) { { is_independent: true } }

          it "returns true" do
            expect(subject.is_independent).to be_truthy
          end
        end
      end

      context "with a persisted org" do
        before do
          organization.save!
        end

        context "when params do not specify is_independent" do
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

        context "when params specify is_independent" do
          context "when the model has a coalition but the params specify is_independent=true" do
            let(:coalition) { build(:coalition) }
            let(:params) { { is_independent: true } }

            it "returns true" do
              expect(subject.is_independent).to be_truthy
            end
          end

          context "when the model does not have a coalition but the params specify is_independent=false" do
            let(:params) { { is_independent: false } }

            it "returns false" do
              expect(subject.is_independent).to be_falsey
            end
          end
        end
      end
    end
  end
end
