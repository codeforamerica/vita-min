require "rails_helper"

describe Hub::Dashboard::ReturnsByStatusPresenter do
  subject do
    Hub::Dashboard::DashboardPresenter.new(user, Ability.new(user), selected_value, stage).returns_by_status_presenter
  end
  let(:coalition) { create :coalition }
  let!(:oregano_org) { create :organization, name: "Oregano Org", coalition: coalition }
  let!(:orangutan_organization) { create :organization, name: "Orangutan Organization", coalition: coalition }
  let!(:tax_return) do
    tax_return = create(:gyr_tax_return, :intake_in_progress, updated_at: 10.days.ago, assigned_user: user)
    tax_return.client.update(vita_partner: oregano_org)
    tax_return
  end
  let(:user) { create :coalition_lead_user, coalition: coalition }
  let(:selected_value) { "coalition/#{coalition.id}" }
  let(:stage) { nil }

  describe "#available_stages_and_states" do
    it "returns available stages and states" do
      expect(subject.available_stage_and_states).to eq TaxReturnStateMachine.available_states_for(role_type: CoalitionLeadRole)
    end
  end

  context "with no stage" do
    it "presents filter options including the coalition and all organizations in the correct order" do
      expect(subject.returns_by_status_total).to eq 1
      expect(subject.returns_by_status.map(&:code)).to eq %w[intake prep review file]
      expect(subject.returns_by_status.map(&:type)).to eq [:stage, :stage, :stage, :stage]
      expect(subject.returns_by_status.map(&:value)).to eq [1, 0, 0, 0]
      expect(subject.returns_by_status_count).to eq 1
    end
  end

  context "with the stage set to intake" do
    let(:stage) { "intake" }

    it "presents filter options including the coalition and all organizations in the correct order" do
      expect(subject.returns_by_status_total).to eq 1
      expect(subject.returns_by_status.map(&:code)).to eq %w[intake_in_progress intake_ready intake_reviewing intake_ready_for_call intake_info_requested intake_greeter_info_requested intake_needs_doc_help]
      expect(subject.returns_by_status.map(&:type)).to eq [:status, :status, :status, :status, :status, :status, :status]
      expect(subject.returns_by_status.map(&:value)).to eq [1, 0, 0, 0, 0, 0, 0]
      expect(subject.returns_by_status_count).to eq 1
    end
  end

  context "with the stage set to review" do
    let(:stage) { "review" }

    it "presents filter options including the coalition and all organizations in the correct order" do
      expect(subject.returns_by_status_total).to eq 1
      expect(subject.returns_by_status.map(&:code)).to eq %w[review_ready_for_qr review_reviewing review_ready_for_call review_signature_requested review_info_requested]
      expect(subject.returns_by_status.map(&:type)).to eq [:status, :status, :status, :status, :status]
      expect(subject.returns_by_status.map(&:value)).to eq [0, 0, 0, 0, 0]
      expect(subject.returns_by_status_count).to eq 0
    end
  end
end