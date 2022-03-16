require 'rails_helper'

describe Ctc::Dependents::ChildQualifiesForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }
    let(:full_time_student) { "yes" }
    let(:permanently_totally_disabled) { "yes" }
    let(:params) do
      {
        full_time_student: full_time_student,
        permanently_totally_disabled: permanently_totally_disabled,
      }
    end

    it "saves the child qualifies fields on the dependent" do
      expect {
        form = described_class.new(dependent, params)
        form.save
      }.to change(dependent, :full_time_student).to("yes")
       .and change(dependent, :permanently_totally_disabled).to("yes")
    end

    context "when none are selected" do
      it "is not valid" do
        form = described_class.new(dependent, params)
        expect(form).not_to be_valid
        expect(form.errors)
      end
    end
  end
end