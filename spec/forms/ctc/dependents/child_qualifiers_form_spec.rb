require 'rails_helper'

describe Ctc::Dependents::ChildQualifiersForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }
    let(:full_time_student) { "yes" }
    let(:permanently_totally_disabled) { "yes" }
    let(:none_of_the_above) { "no" }
    let(:params) do
      {
        full_time_student: full_time_student,
        permanently_totally_disabled: permanently_totally_disabled,
        none_of_the_above: none_of_the_above
      }
    end

    it "saves the child qualifies fields on the dependent" do
      expect {
        form = described_class.new(dependent, params)
        form.save
      }.to change(dependent, :full_time_student).to("yes")
       .and change(dependent, :permanently_totally_disabled).to("yes")
    end

    context "when no items are checked" do
      let(:full_time_student) { "no" }
      let(:permanently_totally_disabled) { "no" }
      let(:none_of_the_above) { "no" }
      it "is not valid" do
        form = described_class.new(dependent, params)
        expect(form).not_to be_valid
        expect(form.errors[:none_of_the_above]).not_to be_blank
      end
    end

    context "when none of the above is selected item" do
      let(:full_time_student) { "no" }
      let(:permanently_totally_disabled) { "no" }
      let(:none_of_the_above) { "yes" }
      it "is valid" do
        form = described_class.new(dependent, params)
        expect(form).to be_valid
        expect(form.errors[:none_of_the_above]).to be_blank
      end
    end
  end
end