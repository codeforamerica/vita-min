require 'rails_helper'

describe Ctc::W2s::MiscInfoForm do
  before { skip }
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
      other_description: "description",
      other_amount: "12",
      box15_state: "NY",
      box15_employer_state_id_number: "abcd1234",
      box16_state_wages: "1",
      box17_state_income_tax: "2",
      box18_local_wages: "3",
      box19_local_income_tax: "4",
      box20_locality_name: "someplace",
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
    expect(w2.w2_box14s.first.other_description).to eq "description"
    expect(w2.w2_box14s.first.other_amount).to eq 12
    expect(w2.w2_state_fields_group.box15_state).to eq "NY"
    expect(w2.w2_state_fields_group.box15_employer_state_id_number).to eq "abcd1234"
    expect(w2.w2_state_fields_group.box16_state_wages).to eq 1
    expect(w2.w2_state_fields_group.box17_state_income_tax).to eq 2
    expect(w2.w2_state_fields_group.box18_local_wages).to eq 3
    expect(w2.w2_state_fields_group.box19_local_income_tax).to eq 4
    expect(w2.w2_state_fields_group.box20_locality_name).to eq "someplace"
  end

  it "updates an existing w2_state_fields_group and w2_box14" do
    w2.create_w2_state_fields_group(box16_state_wages: "100")
    w2.w2_box14.create(other_description: 'banana', other_amount: 12)
    params = {
      other_description: 'papaya',
      other_amount: '24',
      box15_state: "NY",
      box15_employer_state_id_number: "abcd1234",
      box16_state_wages: "1",
      box17_state_income_tax: "2",
      box18_local_wages: "3",
      box19_local_income_tax: "4",
      box20_locality_name: "someplace",
    }
    described_class.new(w2, params).save
    expect(w2.w2_state_fields_group.box16_state_wages).to eq 1
    expect(w2.w2_state_fields_group.box15_state).to eq "NY"
    expect(w2.w2_state_fields_group.box15_employer_state_id_number).to eq "abcd1234"
    expect(w2.w2_state_fields_group.box17_state_income_tax).to eq 2
    expect(w2.w2_state_fields_group.box18_local_wages).to eq 3
    expect(w2.w2_state_fields_group.box19_local_income_tax).to eq 4
    expect(w2.w2_state_fields_group.box20_locality_name).to eq "someplace"
    expect(w2.w2_box14.other_description).to eq 'papaya'
    expect(w2.w2_box14.other_amount).to eq 24
  end

  context "validations" do
    it "can be valid" do
      form = described_class.new(w2, {})
      expect(form).to be_valid
    end

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
      expect(form.errors.attribute_names).not_to include(:box12a)
      expect(form.errors.attribute_names).not_to include(:box12b)
      expect(form.errors.attribute_names).not_to include(:box12c)
      expect(form.errors.attribute_names).not_to include(:box12d)
    end

    it "requires both code and value for all of the 12 boxes if code is present" do
      form = described_class.new(w2, {
        box12a_code: 'A',
        box12b_code: 'B',
        box12c_code: 'D',
        box12d_code: 'AA',
      })

      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box12a)
      expect(form.errors.attribute_names).to include(:box12b)
      expect(form.errors.attribute_names).to include(:box12c)
      expect(form.errors.attribute_names).to include(:box12d)
    end

    it "requires both code and value for all of the 12 boxes if value is present" do
      form = described_class.new(w2, {
        box12a_value: '12.58',
        box12b_value: '45.23',
        box12c_value: '90.12',
        box12d_value: '84.65',
      })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box12a)
      expect(form.errors.attribute_names).to include(:box12b)
      expect(form.errors.attribute_names).to include(:box12c)
      expect(form.errors.attribute_names).to include(:box12d)
    end

    it "requires codes to be in the inclusion list for all of the 12 boxes if code is present" do
      form = described_class.new(w2, {
        box12a_code: 'asdf',
        box12b_code: 'lkj',
        box12c_code: 'asdoifj',
        box12d_code: 'asiodfj',
      })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box12a)
      expect(form.errors.attribute_names).to include(:box12b)
      expect(form.errors.attribute_names).to include(:box12c)
      expect(form.errors.attribute_names).to include(:box12d)
    end

    it "requires values to be dollar amounts for all of the 12 boxes if code is present" do
      form = described_class.new(w2, {
        box12a_value: 'asdf',
        box12b_value: 'lkj',
        box12c_value: 'asdoifj',
        box12d_value: 'asiodfj',
      })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box12a)
      expect(form.errors.attribute_names).to include(:box12b)
      expect(form.errors.attribute_names).to include(:box12c)
      expect(form.errors.attribute_names).to include(:box12d)
    end

    it "requires both description and amount for box 14 if description is present" do
      form = described_class.new(w2, {
        other_description: 'banana',
      })

      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box14)
    end

    it "requires both description and amount for box 14 if amount is present" do
      form = described_class.new(w2, {
        other_amount: '12',
      })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box14)
    end

    it "requires description to be no more than 100 characters long if it is present" do
      form = described_class.new(w2, {
        other_description: 'b'*101,
        other_amount: '12',
      })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box14)
    end

    it "requires amount to look like money if its present" do
      form = described_class.new(w2, {
        other_amount: 'banana',
      })
      form.valid?
      expect(form.errors.attribute_names).to include(:box14)

      params = {
        box16_state_wages: 'RUTABAGA',
      }
      form = described_class.new(w2, params)
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box16_state_wages)
    end

    it "requires both state and employer state id number for box 15 if state is present" do
      form = described_class.new(w2, {
        box15_state: 'NY',
      })

      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box15)
    end

    it "requires both state and employer state id number for box 15 if employer state id number is present" do
      form = described_class.new(w2, {
        box15_employer_state_id_number: '123abc',
      })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box15)
    end

    it "requires state to be in the inclusion list for box 15 if the state is present" do
      form = described_class.new(w2, {
        box15_state: 'asdf',
        box15_employer_state_id_number: '123abc',
      })
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box15)
    end

    it "requires :box16_state_wages to look like money if its present" do
      form = described_class.new(w2, {})
      form.valid?
      expect(form.errors.attribute_names).not_to include(:box16_state_wages)

      params = {
        box16_state_wages: 'RUTABAGA',
      }
      form = described_class.new(w2, params)
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box16_state_wages)
    end

    it "requires :box17_state_income_tax to look like money if its present" do
      form = described_class.new(w2, {})
      form.valid?
      expect(form.errors.attribute_names).not_to include(:box17_state_income_tax)

      params = {
        box17_state_income_tax: 'RUTABAGA',
      }
      form = described_class.new(w2, params)
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box17_state_income_tax)
    end

    it "requires :box18_local_wages to look like money if its present" do
      form = described_class.new(w2, {})
      form.valid?
      expect(form.errors.attribute_names).not_to include(:box18_local_wages)

      params = {
        box18_local_wages: 'RUTABAGA',
      }
      form = described_class.new(w2, params)
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box18_local_wages)
    end

    it "requires :box19_local_income_tax to look like money if its present" do
      form = described_class.new(w2, {})
      form.valid?
      expect(form.errors.attribute_names).not_to include(:box19_local_income_tax)

      params = {
        box19_local_income_tax: 'RUTABAGA',
      }
      form = described_class.new(w2, params)
      expect(form).not_to be_valid
      expect(form.errors.attribute_names).to include(:box19_local_income_tax)
    end
  end
end
