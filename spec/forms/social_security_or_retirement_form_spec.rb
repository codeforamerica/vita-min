require "rails_helper"

describe SocialSecurityOrRetirementForm do
  let(:intake) { create :intake, client: (create :client) }
  subject { described_class.new(intake, { had_social_security_or_retirement: had_social_security_or_retirement })}

  context 'when had_social_security_or_retirement is yes' do
    let(:had_social_security_or_retirement) { "yes" }
    it 'updates had_social_security_or_retirement to yes and leaves gated questions unfilled' do
      subject.save
      intake.reload

      expect(intake.had_social_security_or_retirement).to eq "yes"
      expect(intake.had_social_security_income).to eq "unfilled"
      expect(intake.had_retirement_income).to eq "unfilled"
      expect(intake.paid_retirement_contributions).to eq "unfilled"
    end
  end

  context 'when had social_security_or_retirement is no' do
    let(:had_social_security_or_retirement) { "no" }
    it 'updates had_social_security_or_retirement to no and makes gated questions no' do
      subject.save
      intake.reload

      expect(intake.had_social_security_or_retirement).to eq "no"
      expect(intake.had_social_security_income).to eq "no"
      expect(intake.had_retirement_income).to eq "no"
      expect(intake.paid_retirement_contributions).to eq "no"
    end
  end
end