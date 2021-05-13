require "rails_helper"

describe ItemizingForm do
  let(:intake) { create :intake, client: (create :client) }
  subject { described_class.new(intake, { wants_to_itemize: wants_to_itemize })}

  context 'when wants_to_itemize is yes' do
    let(:wants_to_itemize) { "yes" }
    it 'updates wants_to_itemize to yes and leaves gated questions unfilled' do
      subject.save
      intake.reload

      expect(intake.wants_to_itemize).to eq "yes"
      expect(intake.paid_medical_expenses).to eq "unfilled"
      expect(intake.had_gambling_income).to eq "unfilled"
      expect(intake.paid_school_supplies).to eq "unfilled"
      expect(intake.paid_local_tax).to eq "unfilled"
      expect(intake.had_local_tax_refund).to eq "unfilled"
    end
  end

  context 'when wants_to_itemize is unsure' do
    let(:wants_to_itemize) { "unsure" }
    it 'updates wants_to_itemize to yes and leaves gated questions unfilled' do
      subject.save
      intake.reload

      expect(intake.wants_to_itemize).to eq "unsure"
      expect(intake.paid_medical_expenses).to eq "unfilled"
      expect(intake.had_gambling_income).to eq "unfilled"
      expect(intake.paid_school_supplies).to eq "unfilled"
      expect(intake.paid_local_tax).to eq "unfilled"
      expect(intake.had_local_tax_refund).to eq "unfilled"
    end
  end

  context 'when had social_security_or_retirement is no' do
    let(:wants_to_itemize) { "no" }
    it 'updates wants_to_itemize to no and makes gated questions no' do
      subject.save
      intake.reload

      expect(intake.wants_to_itemize).to eq "no"
      expect(intake.paid_medical_expenses).to eq "no"
      expect(intake.had_gambling_income).to eq "no"
      expect(intake.paid_school_supplies).to eq "no"
      expect(intake.paid_local_tax).to eq "no"
      expect(intake.had_local_tax_refund).to eq "no"
    end
  end
end