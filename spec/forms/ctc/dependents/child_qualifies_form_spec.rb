require 'rails_helper'

describe Ctc::Dependents::ChildQualifiesForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }
    let(:params) do
      {
        full_time_student: "yes",
        permanently_totally_disabled: "yes",
      }
    end

    it "saves the child qualifies fields on the dependent" do
      expect {
        form = described_class.new(dependent, params)
        form.save
      }.to change(dependent, :full_time_student).to("yes")
       .and change(dependent, :permanently_totally_disabled).to("yes")
    end
  end
end