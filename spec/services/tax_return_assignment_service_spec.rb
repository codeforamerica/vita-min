require "rails_helper"

describe TaxReturnAssignmentService do
  subject do
    TaxReturnAssignmentService.new(tax_return: tax_return,
                                   assigned_user: assigned_user,
                                   assigned_by: assigned_by)
  end

  describe ".assign" do
    let(:tax_return) { create :gyr_tax_return, assigned_user: (create :site_coordinator_user) }
    let(:assigned_user) { create :team_member_user }
    let(:assigned_by) { create :user }

    context "when assigned_user_id is nil" do
      let(:assigned_user) { nil }

      it "updates the assigned user to be nil" do
        expect { subject.assign! }.to change(tax_return.reload, :assigned_user_id).to(nil)
      end
    end

    context "when assigned_user_id is present" do
      it "updates the user" do
        expect { subject.assign! }.to change(tax_return.reload, :assigned_user_id).to(assigned_user.id)
      end

      context "when assigned user has a different vita partner than the clients" do
        let(:tax_return) { create :gyr_tax_return, assigned_user: (create :user), client: create(:client, vita_partner: old_site) }
        let(:assigned_user) { create :user, role: create(:team_member_role, site: new_site) }
        let(:new_site) { create :site }
        let(:old_site) { create :site }

        let(:instance) { instance_double(UpdateClientVitaPartnerService) }
        let(:double_class) { class_double(UpdateClientVitaPartnerService).as_stubbed_const }

        before do
          allow(double_class).to receive(:new).and_return(instance)
          allow(instance).to receive(:update!)
        end

        it "calls the UpdateClientVitaPartnerService" do
          expect{ subject.assign! }.not_to raise_error
          expect(instance).to have_received(:update!).once
        end
      end
    end
  end

  describe ".send_notifications" do
    let(:tax_return) { create :gyr_tax_return, assigned_user: (create :site_coordinator_user) }
    let(:assigned_user) { create :team_member_user }
    let(:assigned_by) { create :user }

    context "when assigned_user_id is nil" do
      let(:assigned_user) { nil }
      it "creates a note, does not send email" do
        expect {
          subject.send_notifications
        }.to change(SystemNote, :count).by(1)
        expect(AssignmentEmail.count).to be_zero
      end
    end

    context "when assigned_user_id is present" do
      it "creates a system note, creates an AssignmentEmail, and enqueues a job to send the assignment email" do
        expect {
          subject.send_notifications
        }.to change(SystemNote, :count).by(1)
           .and change(AssignmentEmail, :count).by(1)
           .and have_enqueued_job(SendAssignmentEmailJob)
        assignment_email = AssignmentEmail.last
        expect(assignment_email.assigned_user).to eq assigned_user
        expect(assignment_email.assigning_user).to eq assigned_by
        expect(assignment_email.tax_return).to eq tax_return
        expect(assignment_email.assigned_at).to eq tax_return.updated_at
      end
    end
  end
end