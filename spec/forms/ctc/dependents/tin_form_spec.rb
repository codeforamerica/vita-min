require 'rails_helper'

describe Ctc::Dependents::TinForm do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake, tin_type: nil, ssn: ssn, birth_date: nil }
  let(:ssn) { nil }

  context "validations" do
    it "requires tin_type" do
      form = described_class.from_dependent(dependent)
      expect(form).not_to be_valid
      expect(form.errors.keys).to include(:tin_type)
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
end
