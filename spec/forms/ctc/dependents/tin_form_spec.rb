require 'rails_helper'

describe Ctc::Dependents::TinForm do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake, tin_type: nil, ssn: ssn, birth_date: nil }
  let(:ssn) { nil }

  context "initialization with from_dependent" do
    let(:dependent) { create :dependent, intake: intake, ssn: ssn, birth_date: nil, tin_type: "ssn_no_employment" }

    context "coercing tin_type to the correct value when ssn_no_employment" do
      it "sets ssn_no_employment to yes, and primary_tin_type to ssn" do
        form = described_class.from_dependent(dependent)
        expect(form.tin_type).to eq "ssn"
        expect(form.ssn_no_employment).to eq "yes"
      end
    end
  end

  context "validations" do
    it "requires tin_type" do
      form = described_class.from_dependent(dependent)
      expect(form).not_to be_valid
      expect(form.errors.keys).to include(:tin_type)
    end

    context "there is no tin/ssn entered" do
      let(:dependent) { create :dependent, intake: intake, tin_type: "ssn", ssn: nil, birth_date: nil }
      it "is not valid" do
        form = described_class.from_dependent(dependent)
        expect(form).not_to be_valid
        expect(form.errors.keys).to include(:ssn)
      end
    end

    describe 'ssn_confirmation' do
      context 'if ssn was blank' do
        let(:ssn) { nil }

        it "is required" do
          form = described_class.from_dependent(dependent)
          form.assign_attributes(ssn: '555112222')
          expect(form).not_to be_valid
          expect(form.errors.keys).to include(:ssn_confirmation)
        end
      end

      context 'if ssn was changed' do
        let(:ssn) { '555113333' }

        it "is required" do
          form = described_class.from_dependent(dependent)
          form.assign_attributes(ssn: '555112222')
          expect(form).not_to be_valid
          expect(form.errors.keys).to include(:ssn_confirmation)
        end
      end

      context 'if ssn was not changed' do
        let(:ssn) { '555112222' }

        it "is not required" do
          form = described_class.from_dependent(dependent)
          form.assign_attributes(ssn: '555112222')
          form.valid?
          expect(form.errors.keys).not_to include(:ssn_confirmation)
        end
      end
    end
  end

  describe "#save" do
    let(:params) {
      {
        tin_type: tin_type,
        ssn_no_employment: ssn_no_employment,
      }
    }
    context "when tin type is ssn" do
      let(:tin_type) { "ssn" }
      context "when the ssn_no_employment checkbox is value yes" do
        let(:ssn_no_employment) { "yes" }

        it "has a resulting tin type of ssn_no_employment" do
          form = described_class.new(dependent, params)
          form.valid?
          form.save
          Dependent.last.tin_type = "ssn_no_employment"
        end
      end

      context "when the ssn_no_employment checkbox value is no" do
        let(:ssn_no_employment) { "no" }

        it "has a resulting tin type of ssn" do
          form = described_class.new(dependent, params)
          form.valid?
          form.save
          Dependent.last.tin_type = "ssn"
        end
      end
    end

    context "when tin type is not ssn" do
      let(:ssn_no_employment) { "no" }
      let(:tin_type) { "itin" }

      it "sets the tin type to itin" do
        form = described_class.new(dependent, params)
        form.valid?
        form.save
        Dependent.last.tin_type = "itin"
      end
    end
  end
end
