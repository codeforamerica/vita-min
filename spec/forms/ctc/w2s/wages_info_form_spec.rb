require 'rails_helper'

describe Ctc::W2s::WagesInfoForm do
  let(:completed_at) { nil }
  let(:w2) { create :w2, intake: intake, completed_at: completed_at }
  let(:intake) { create :ctc_intake }

  it "saves the values correctly" do
    params = {
      wages_amount: '$9,900.01',
      federal_income_tax_withheld: '$8,800.01',
    }
    described_class.new(w2, params).save
    expect(w2.wages_amount).to eq 9900.01
    expect(w2.federal_income_tax_withheld).to eq 8800.01
  end

  context "when completing the form and the answer for box 8 or 10 disqualifies you from simplified filing and completed_at is not set" do
    it "saves completed_at" do
      freeze_time do
        expect {
          described_class.new(w2, { box8_allocated_tips: '10' }).save
        }.to change { w2.reload.completed_at }.from(nil).to(DateTime.now)
      end
    end
  end

  context "when no disqualifying answer" do
    it "does not save completed_at" do
      expect {
        described_class.new(w2, {}).save
      }.not_to(change { w2.reload.completed_at })
    end
  end

  context "when completed_at has been set" do
    let(:completed_at) { 1.week.ago }

    it "does not change completed_at" do
      expect {
        described_class.new(w2, { box8_allocated_tips: '10' }).save
      }.not_to(change { w2.reload.completed_at })
    end

    context "validations" do
      it "requires wages to be present and look like money" do
        form = described_class.new(w2, {})
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to include(:wages_amount)

        form = described_class.new(w2, { wages_amount: 'RUTABAGA' })
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to include(:wages_amount)
      end

      it "requires federal_income_tax_withheld to be present and look like money" do
        form = described_class.new(w2, {})
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to include(:federal_income_tax_withheld)

        form = described_class.new(w2, { federal_income_tax_withheld: 'RUTABAGA.' })
        expect(form).not_to be_valid
        expect(form.errors.attribute_names).to include(:federal_income_tax_withheld)
      end

      it "allows federal_income_tax_withheld less than wages_amount" do
        form = described_class.new(w2, { federal_income_tax_withheld: '8,000', wages_amount: '$9,000.01' })
        expect(form).to be_valid
      end

      it "disallows federal_income_tax_withheld greater than or equal to wages_amount" do
        form = described_class.new(w2, { federal_income_tax_withheld: '100', wages_amount: '90' })
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
end

