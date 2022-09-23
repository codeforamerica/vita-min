require 'rails_helper'

describe Ctc::W2s::MiscInfoForm do
  let(:w2) { create(:w2, completed_at: completed_at) }
  let(:completed_at) { nil }

  context "when completing the form for the first time" do
    it "saves completed_at" do
      freeze_time do
        expect {
          described_class.new(w2, {}).save
        }.to change { w2.reload.completed_at }.from(nil).to(DateTime.now)
      end
    end
  end

  context "when completing it a second time" do
    let(:completed_at) { 1.day.ago }

    it "does not change completed_at" do
      expect {
        described_class.new(w2, {}).save
      }.not_to change { w2.reload.completed_at }
    end
  end

  it "persists the attributes" do
    params = {
      box11_nonqualified_plans: '123',
      box12a_code: 'AA',
      box12a_value: '5',
      box12b_code: 'E',
      box12b_value: '6',
      box12c_code: 'L',
      box12c_value: '7',
      box12d_code: 'M',
      box12d_value: '8',
      box13_statutory_employee: 'yes',
      box13_retirement_plan: 'yes',
      box13_third_party_sick_pay: 'no',
    }
    described_class.new(w2, params).save
    expect(w2.box11_nonqualified_plans).to eq 123
    expect(w2.box12a_code).to eq 'AA'
    expect(w2.box12a_value).to eq 5
    expect(w2.box12b_code).to eq 'E'
    expect(w2.box12b_value).to eq 6
    expect(w2.box12c_code).to eq 'L'
    expect(w2.box12c_value).to eq 7
    expect(w2.box12d_code).to eq 'M'
    expect(w2.box12d_value).to eq 8
    expect(w2.box13_statutory_employee).to eq 'yes'
    expect(w2.box13_retirement_plan).to eq 'yes'
    expect(w2.box13_third_party_sick_pay).to eq 'no'
  end

  context "validations" do
    it "requires :box11_nonqualified_plans to look like money if its present" do
      form = described_class.new(w2, {})
      form.valid?
      expect(form.errors.attribute_names).not_to include(:box11_nonqualified_plans)

      params = {
        box11_nonqualified_plans: 'RUTABAGA',
      }
      form = described_class.new(w2, params)
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box11_nonqualified_plans)
    end

    it "does not require the 12s" do
      form = described_class.new(w2, {})
      form.valid?
      expect(form.errors.attribute_names).not_to include(:box12a_code)
      expect(form.errors.attribute_names).not_to include(:box12a_value)
      expect(form.errors.attribute_names).not_to include(:box12b_code)
      expect(form.errors.attribute_names).not_to include(:box12b_value)
      expect(form.errors.attribute_names).not_to include(:box12c_code)
      expect(form.errors.attribute_names).not_to include(:box12c_value)
      expect(form.errors.attribute_names).not_to include(:box12d_code)
      expect(form.errors.attribute_names).not_to include(:box12d_value)
    end

    it "requires both code and value for all of the 12 boxes if code is present" do
      form = described_class.new(w2, {
        box12a_code: 'A',
        box12b_code: 'B',
        box12c_code: 'D',
        box12d_code: 'AA',
      })

      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box12a_value)
      expect(form.errors.attribute_names).to include(:box12b_value)
      expect(form.errors.attribute_names).to include(:box12c_value)
      expect(form.errors.attribute_names).to include(:box12d_value)
    end

    it "requires both code and value for all of the 12 boxes if value is present" do
      form = described_class.new(w2, {
        box12a_value: '12.58',
        box12b_value: '45.23',
        box12c_value: '90.12',
        box12d_value: '84.65',
      })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box12a_code)
      expect(form.errors.attribute_names).to include(:box12b_code)
      expect(form.errors.attribute_names).to include(:box12c_code)
      expect(form.errors.attribute_names).to include(:box12d_code)
    end

    it "requires codes to be in the inclusion list for all of the 12 boxes if code is present" do
      form = described_class.new(w2, {
        box12a_code: 'asdf',
        box12b_code: 'lkj',
        box12c_code: 'asdoifj',
        box12d_code: 'asiodfj',
      })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box12a_code)
      expect(form.errors.attribute_names).to include(:box12b_code)
      expect(form.errors.attribute_names).to include(:box12c_code)
      expect(form.errors.attribute_names).to include(:box12d_code)
    end

    it "requires values to be dollar amounts for all of the 12 boxes if code is present" do
      form = described_class.new(w2, {
        box12a_value: 'asdf',
        box12b_value: 'lkj',
        box12c_value: 'asdoifj',
        box12d_value: 'asiodfj',
      })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box12a_value)
      expect(form.errors.attribute_names).to include(:box12b_value)
      expect(form.errors.attribute_names).to include(:box12c_value)
      expect(form.errors.attribute_names).to include(:box12d_value)
    end
  end
end
