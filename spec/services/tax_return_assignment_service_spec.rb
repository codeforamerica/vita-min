require "rails_helper"

describe TaxReturnAssignmentService do
  subject do
    TaxReturnAssignmentService.new(tax_return: tax_return,
                                   assigned_user: assigned_user,
                                   assigned_by: assigned_by)
  end

  describe ".assign" do
    let(:site) { create(:site) }
    let(:tax_return) { create :gyr_tax_return, assigned_user: (create :site_coordinator_user) }
    let(:assigned_user) { create :team_member_user, sites: [site] }
    let(:assigned_by) { create :user }

    before do
      tax_return.client.update(vita_partner: site)
    end

    it "creates a note, does not send email" do
      expect {
        subject.assign!
      }.to change(SystemNote::AssignmentChange, :count).by(1)
    end

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
        let(:assigned_user) { create :user, role: create(:team_member_role, sites: [new_site]) }
        let(:organization) { create :organization }
        let(:new_site) { create :site, parent_organization: organization }
        let(:old_site) { create :site, parent_organization: organization }

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

        context "when being assigned to a team member with multiple sites" do
          let(:another_new_site) { create :site, parent_organization: organization }
          let(:assigned_user) { create :user, role: create(:team_member_role, sites: [new_site, another_new_site]) }

          it "assigns to the first site" do
            expect{ subject.assign! }.not_to raise_error
            expect(instance).to have_received(:update!).once
          end
        end
      end
    end

    context "when assigned_user is a org lead" do
      let(:assigned_user) { create :organization_lead_user, organization: create(:organization, child_sites: [site]) }

      it "updates the user" do
        expect { subject.assign! }.to change(tax_return.reload, :assigned_user_id).to(assigned_user.id)
      end

      context "their original vita partner is a site" do
        it "keeps them at the site" do
          expect { subject.assign! }.not_to change(tax_return.client.reload, :vita_partner)
          expect(tax_return.client.vita_partner).to eq site
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
      it "does not send email" do
        expect {
          subject.send_notifications
        }.not_to change(InternalEmail, :count).from(0)
      end
    end

    context "when assigned_user_id is present" do
      it "creates a system note, creates an InternalEmail, and enqueues a job to send the assignment email" do
        expect {
          subject.send_notifications
        }.to change(InternalEmail, :count).by(1)
                                             .and have_enqueued_job(SendInternalEmailJob)
        mail_args = InternalEmail.last.deserialized_mail_args
        expect(mail_args[:assigned_user]).to eq assigned_user
        expect(mail_args[:assigning_user]).to eq assigned_by
        expect(mail_args[:tax_return]).to eq tax_return
        expect(mail_args[:assigned_at]).to eq tax_return.updated_at
      end
    end
  end
end
