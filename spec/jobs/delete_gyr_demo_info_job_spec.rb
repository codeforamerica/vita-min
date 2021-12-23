require 'rails_helper'

RSpec.describe DeleteGyrDemoInfoJob, type: :job do
  describe "#perform" do
    let!(:ctc_client) { create :client, intake: (create :ctc_intake) }
    let!(:gyr_client) { create :client, intake: (create :intake), vita_partner: orange_org }
    let!(:gyr_intake) { gyr_client.intake }
    let!(:tax_return) { create :tax_return, :file_ready_to_file, assigned_user: admin_user, client: gyr_client, year: 2021 }

    let!(:admin_user) { create :admin_user }
    let!(:greeter_user) { create :greeter_user }
    let!(:site_coordinator_user) { create :site_coordinator_user }

    let!(:orange_org) { create(:organization, name: "Orange Organization") }
    let!(:papaya_org) { create(:organization, name: "Papaya Organization") }
    let!(:snake_site) { create(:site, name: "Snake Site", parent_organization: papaya_org) }

    context "when there are clients and associated records that should be exempted from deletion" do
      let!(:sage_site) { create(:site, name: "Sage Site", parent_organization: papaya_org) }
      let!(:gyr_client_exempted) { create :client, intake: (create :intake), vita_partner: sage_site }
      let!(:gyr_client_exempted_2) { create :client, intake: (create :intake), vita_partner: sage_site }
      let!(:tax_return_exempted) { create :tax_return, :intake_in_progress, assigned_user: admin_user, client: gyr_client_exempted, year: 2021 }

      it "only delete non-exempted clients and their associated records" do
        expect do
          described_class.perform_now([gyr_client_exempted.id, gyr_client_exempted_2.id])
        end.to change(Client, :count).by(-1).and change(TaxReturn, :count).by(-1).and change(Intake, :count).by(-1)

        expect(gyr_client_exempted.reload).to be_present
        expect(gyr_client_exempted_2.reload).to be_present
        expect(tax_return_exempted.reload).to be_present
        expect(gyr_client_exempted.intake.reload).to be_present

        expect { gyr_client.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { tax_return.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { gyr_intake.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "does not delete orgs and sites with exempted client associations" do
        described_class.perform_now([gyr_client_exempted.id, gyr_client_exempted_2.id])

        expect { orange_org.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { snake_site.reload }.to raise_error(ActiveRecord::RecordNotFound)

        expect(papaya_org.reload).to be_present
        expect(sage_site.reload).to be_present
      end
    end

    it "only deletes GYR records and not CTC records" do
      expect { described_class.perform_now([]) }.to change(Intake::CtcIntake, :count).by(0)

      expect(ctc_client.reload).to be_present
    end

    it "deletes orgs and sites" do
      expect do
        described_class.perform_now([])
      end.to change(Organization, :count).by(-3).and change(Site, :count).by(-2)

      expect { orange_org.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { papaya_org.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { snake_site.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "in the production environment" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "does not make db changes" do
        expect do
          described_class.perform_now([])
        end.to change(Client, :count).by(0).and change(Organization, :count).by(0)
      end
    end

    context "users with assigned tax returns of exempted clients" do
      let!(:tax_return_2) { create :tax_return, :file_ready_to_file, assigned_user: site_coordinator_user, client: gyr_client, year: 2020 }
      let!(:tax_return_3) { create :tax_return, :file_ready_to_file, assigned_user: greeter_user, year: 2021 }

      it "deletes non-admin users" do
        described_class.perform_now([gyr_client.id])

        expect(admin_user.reload).to be_present
        expect(tax_return_2.reload).to be_present
        expect(tax_return_2.reload.assigned_user).to be_nil
        expect { site_coordinator_user.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect { greeter_user.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end