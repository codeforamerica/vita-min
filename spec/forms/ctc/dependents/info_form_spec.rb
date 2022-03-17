require 'rails_helper'

describe Ctc::Dependents::InfoForm do
  let(:dependent) { create :dependent, intake: intake }
  let(:intake) { create :ctc_intake }
  let(:ssn) { nil }
  let(:tin_type) { "ssn_no_employment" }
  let(:params) do
    {
      ssn: ssn,
      tin_type: tin_type
    }
  end

  context "initialization with from_dependent" do
    let(:dependent) { create :dependent, intake: intake, ssn: ssn, tin_type: "ssn_no_employment" }
    context "coercing tin_type to the correct value when ssn_no_employment" do
      it "sets ssn_no_employment to yes, and primary_tin_type to ssn" do
        form = described_class.from_dependent(dependent)
        expect(form.tin_type).to eq "ssn"
        expect(form.ssn_no_employment).to eq "yes"
      end
    end
  end

  context "validations" do
    it "requires first and last name" do
      form = described_class.new(dependent, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:first_name)
      expect(form.errors.attribute_names).to include(:last_name)
    end

    it "requires relationship" do
      form = described_class.new(dependent, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:relationship)
    end

    it "requires birth date" do
      form = described_class.new(dependent, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:birth_date)

      form.assign_attributes(birth_date_month: '1', birth_date_day: '1', birth_date_year: 1.year.ago.year.to_s)
      form.valid?
      expect(form.errors.attribute_names).not_to include(:birth_date)
    end

    it "requires tin_type" do
      form = described_class.new(dependent, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:tin_type)
    end

    context "tin_type is atin" do
      let(:tin_type) { "atin" }
      let(:ssn) { "123456789" }

      it "requires valid atin number" do
        form = described_class.new(dependent, params)
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to include(:ssn)
      end
    end

    context "there is no tin/ssn entered" do
      let(:dependent) { create :dependent, intake: intake, tin_type: "ssn", ssn: nil }
      it "is not valid" do
        form = described_class.from_dependent(dependent)
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to include(:ssn)
      end
    end

    describe 'ssn_confirmation' do
      context 'if ssn was blank' do
        let(:ssn) { nil }

        it "is required" do
          form = described_class.from_dependent(dependent)
          form.assign_attributes(ssn: '555112222')
          form.assign_attributes(ssn_confirmation: "1")
          expect(form).not_to be_valid
          expect(form.errors.attribute_names).to include(:ssn_confirmation)
          expect(form.errors[:ssn_confirmation]).to include "Please double check that the provided numbers match."
        end
      end

      context 'if ssn was changed' do
        let(:ssn) { '555113333' }

        it "is required" do
          form = described_class.from_dependent(dependent)
          form.assign_attributes(ssn: '555112222')
          expect(form).not_to be_valid
          expect(form.errors.attribute_names).to include(:ssn_confirmation)
        end
      end

      context 'if ssn was not changed' do
        let(:dependent) { create :dependent, intake: intake, ssn:'555112222', tin_type: "ssn" }

        it "is not required" do
          form = described_class.from_dependent(dependent)
          form.assign_attributes(ssn: '555112222')
          form.valid?
          expect(form.errors.attribute_names).not_to include(:ssn_confirmation)
        end
      end
    end
  end

  describe '#save' do
    let(:intake) { build(:ctc_intake) }
    let(:tin) { "123456789" }
    let(:params) do
      {
        first_name: 'Fae',
        last_name: 'Taxseason',
        suffix: 'Jr',
        birth_date_day: 1,
        birth_date_month: 1,
        birth_date_year: 1.year.ago.year,
        relationship: "daughter",
        tin_type: tin_type,
        filed_joint_return: "yes",
        ssn_no_employment: ssn_no_employment,
        ssn: tin,
        ssn_confirmation: tin
      }
    end
    let(:tin_type) { "ssn" }
    let(:ssn_no_employment) { "no" }

    it "saves the attributes on the dependent" do
      form = described_class.new(intake.dependents.new, params)
      expect(form).to be_valid
      form.save

      dependent = Dependent.last
      expect(dependent.first_name).to eq "Fae"
      expect(dependent.last_name).to eq "Taxseason"
      expect(dependent.suffix).to eq "Jr"
    end

    context "when tin type is ssn" do
      let(:tin_type) { "ssn" }
      context "when the ssn_no_employment checkbox is value yes" do
        let(:ssn_no_employment) { "yes" }

        it "has a resulting tin type of ssn_no_employment" do
          form = described_class.new(dependent, params)
          form.valid?
          form.save
          expect(Dependent.last.tin_type).to eq "ssn_no_employment"
        end
      end

      context "when the ssn_no_employment checkbox value is no" do
        let(:ssn_no_employment) { "no" }

        it "has a resulting tin type of ssn" do
          form = described_class.new(dependent, params)
          form.valid?
          form.save
          expect(Dependent.last.tin_type).to eq "ssn"
        end
      end
    end

    context "when tin type is atin" do
      let(:ssn_no_employment) { "no" }
      let(:tin_type) { "atin" }
      let(:tin) { "912931234" }

      context "when the number is a valid atin" do
        it "sets the tin type to atin and persists the number" do
          form = described_class.new(dependent, params)
          expect(form.valid?).to eq true
          form.save
          expect(dependent.reload.tin_type).to eq "atin"
        end
      end

      context "when the number is not a valid atin" do
        let(:tin) { "123456789" }
        it "is not valid and adds an error to the form" do
          form = described_class.new(dependent, params)
          expect(form.valid?).to eq false
          expect(form.errors[:ssn]).to include "Please enter a valid adoption taxpayer identification number."
        end
      end

      it "sets the tin type to atin" do
        form = described_class.new(dependent, params)
        form.valid?
        form.save
        expect(Dependent.last.tin_type).to eq "atin"
      end
    end

    context "when the client is born in the final 6 months of the current tax year" do
      before do
        params[:birth_date_day] = 7
        params[:birth_date_month] = 7
        params[:birth_date_year] = TaxReturn.current_tax_year
      end

      it "sets lived_with_for_more_than_6_months to true" do
        form = described_class.new(dependent, params)
        form.save
        expect(Dependent.last.lived_with_more_than_six_months).to eq "yes"
      end
    end
  end
end
