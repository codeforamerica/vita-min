require 'rails_helper'

describe Ctc::W2s::WagesInfoForm do
  let(:w2) { create :w2, intake: intake }
  let(:intake) { create :ctc_intake }

  context "validations" do
    it "requires wages to be present and look like money" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:wages_amount)

      form = described_class.new(w2, { wages_amount: 'RUTABAGA'})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:wages_amount)
    end

    it "requires federal_income_tax_withheld to be present and look like money" do
      form = described_class.new(w2, {})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:federal_income_tax_withheld)

      form = described_class.new(w2, { federal_income_tax_withheld: 'RUTABAGA'})
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:federal_income_tax_withheld)
    end

    it "requires :box3_social_security_wages, :box4_social_security_tax_withheld, :box5_medicare_wages_and_tip_amount, :box6_medicare_tax_withheld, :box7_social_security_tips_amount, :box8_allocated_tips, :box10_dependent_care_benefits to look like money" do
      form = described_class.new(w2, {})
      form.valid?
      expect(form.errors.attribute_names).not_to include(:box3_social_security_wages)
      expect(form.errors.attribute_names).not_to include(:box4_social_security_tax_withheld)
      expect(form.errors.attribute_names).not_to include(:box5_medicare_wages_and_tip_amount)
      expect(form.errors.attribute_names).not_to include(:box6_medicare_tax_withheld)
      expect(form.errors.attribute_names).not_to include(:box7_social_security_tips_amount)
      expect(form.errors.attribute_names).not_to include(:box8_allocated_tips)
      expect(form.errors.attribute_names).not_to include(:box10_dependent_care_benefits)

      params = {
        box3_social_security_wages: 'RUTABAGA',
        box4_social_security_tax_withheld: 'RUTABAGA',
        box5_medicare_wages_and_tip_amount: 'RUTABAGA',
        box6_medicare_tax_withheld: 'RUTABAGA',
        box7_social_security_tips_amount: 'RUTABAGA',
        box8_allocated_tips: 'RUTABAGA',
        box10_dependent_care_benefits: 'RUTABAGA',
      }
      form = described_class.new(w2, params)
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box3_social_security_wages)
      expect(form.errors.attribute_names).to include(:box4_social_security_tax_withheld)
      expect(form.errors.attribute_names).to include(:box5_medicare_wages_and_tip_amount)
      expect(form.errors.attribute_names).to include(:box6_medicare_tax_withheld)
      expect(form.errors.attribute_names).to include(:box7_social_security_tips_amount)
      expect(form.errors.attribute_names).to include(:box8_allocated_tips)
      expect(form.errors.attribute_names).to include(:box10_dependent_care_benefits)
    end
  end
end
