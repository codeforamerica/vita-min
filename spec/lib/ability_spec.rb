require "rails_helper"

describe Ability do
  let(:subject) { Ability.new(user) }

  context "as an admin" do
    let(:user) { create(:user, role: create(:admin_role)) }

    it "can manage everything" do
      expect(subject.can?(:manage, Document.new)).to eq true
      expect(subject.can?(:manage, IncomingEmail.new)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new)).to eq true
      expect(subject.can?(:manage, Note.new)).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new)).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new)).to eq true
      expect(subject.can?(:manage, SystemNote.new)).to eq true
      expect(subject.can?(:manage, User.new)).to eq true
      expect(subject.can?(:manage, VitaPartner.new)).to eq true
    end

    context "with a client data unrelated to the user" do
      let(:client) { create(:client, vita_partner: create(:organization)) }

      it "can manage all" do
        expect(subject.can?(:manage, client)).to eq true
        expect(subject.can?(:destroy, client)).to eq true
        expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq true
        expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq true
        expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq true
        expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq true
        expect(subject.can?(:manage, Document.new(client: client))).to eq true
        expect(subject.can?(:manage, Note.new(client: client))).to eq true
      end
    end
  end

  context "as a non-admin" do
    context "Permissions regarding Clients and their data" do
      shared_examples :cannot_manage_any_sites_or_orgs do
        it "cannot manage any VitaPartner records" do
          expect(subject.can?(:manage, VitaPartner)).to eq(false)
        end

        context "when the user can access a particular site" do
          let(:accessible_site) { create(:site) }
          let(:accessible_client) { create(:client, vita_partner: accessible_site) }
          before do
            allow(user).to receive(:accessible_vita_partners).and_return(VitaPartner.where(id: accessible_site))
          end

          it "cannot manage the site" do
            expect(subject.can?(:manage, accessible_site)).to eq false
          end
        end
      end

      shared_examples :can_only_read_accessible_org_or_site do
        let(:accessible_site) { create(:site) }
        before do
          allow(user).to receive(:accessible_vita_partners).and_return(Site.where(id: accessible_site))
        end

        it "can read the site" do
          expect(subject.can?(:read, accessible_site)).to eq true
        end

        it "cannot read a random site" do
          expect(subject.can?(:read, create(:site))).to eq false
        end
      end

      shared_examples :can_manage_but_not_delete_accessible_client do
        context "when the user can access a particular site" do
          let(:accessible_site) { create(:site) }
          let(:accessible_client) { create(:client, vita_partner: accessible_site) }
          before do
            allow(user).to receive(:accessible_vita_partners).and_return(VitaPartner.where(id: accessible_site))
          end

          it "can access all data for the client" do
            expect(subject.can?(:manage, accessible_client)).to eq true
            expect(subject.can?(:manage, Document.new(client: accessible_client))).to eq true
            expect(subject.can?(:manage, IncomingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:manage, IncomingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:manage, Note.new(client: accessible_client))).to eq true
            expect(subject.can?(:manage, OutgoingEmail.new(client: accessible_client))).to eq true
            expect(subject.can?(:manage, OutgoingTextMessage.new(client: accessible_client))).to eq true
            expect(subject.can?(:manage, SystemNote.new(client: accessible_client))).to eq true
            expect(subject.can?(:manage, TaxReturn.new(client: accessible_client))).to eq true
          end

          it "cannot delete a client" do
            expect(subject.can?(:destroy, accessible_client)).to eq false
          end
        end
      end

      shared_examples :cannot_manage_inaccessible_client do
        context "when the user cannot access a particular site" do
          let(:inaccessible_site) { create(:site) }
          let(:inaccessible_client) { create(:client, vita_partner: inaccessible_site) }
          before do
            allow(user).to receive(:accessible_vita_partners).and_return(VitaPartner.none)
          end

          it "can access no data for the client" do
            expect(subject.can?(:manage, inaccessible_client)).to eq false
            expect(subject.can?(:manage, Document.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, IncomingEmail.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, IncomingTextMessage.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, Note.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, OutgoingEmail.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, OutgoingTextMessage.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, SystemNote.new(client: inaccessible_client))).to eq false
            expect(subject.can?(:manage, TaxReturn.new(client: inaccessible_client))).to eq false
          end
        end

      end

      context "users with valid non-admin roles" do
        context "a coalition lead" do
          let(:user) { create :coalition_lead_user }

          it_behaves_like :can_manage_but_not_delete_accessible_client
          it_behaves_like :cannot_manage_inaccessible_client
          it_behaves_like :can_only_read_accessible_org_or_site
          it_behaves_like :cannot_manage_any_sites_or_orgs
        end

        context "an organization lead" do
          let(:user) { create :organization_lead_user }

          it_behaves_like :can_manage_but_not_delete_accessible_client
          it_behaves_like :cannot_manage_inaccessible_client
          it_behaves_like :can_only_read_accessible_org_or_site
          it_behaves_like :cannot_manage_any_sites_or_orgs
        end

        context "a site coordinator" do
          let(:user) { create :site_coordinator_user }

          it_behaves_like :can_manage_but_not_delete_accessible_client
          it_behaves_like :cannot_manage_inaccessible_client
          it_behaves_like :can_only_read_accessible_org_or_site
          it_behaves_like :cannot_manage_any_sites_or_orgs
        end

        context "a team member" do
          let(:user) { create :team_member_user }

          it_behaves_like :can_manage_but_not_delete_accessible_client
          it_behaves_like :cannot_manage_inaccessible_client
          it_behaves_like :can_only_read_accessible_org_or_site
          it_behaves_like :cannot_manage_any_sites_or_orgs
        end

        context "a greeter" do
          let(:user) { create :greeter_user }

          it_behaves_like :can_manage_but_not_delete_accessible_client
          it_behaves_like :cannot_manage_inaccessible_client
          it_behaves_like :can_only_read_accessible_org_or_site
          it_behaves_like :cannot_manage_any_sites_or_orgs
        end
      end

      context "users in invalid states" do
        context "a nil user" do
          let(:user) { nil }
          let(:organization) { create :organization }
          let(:client) { create(:client, vita_partner: organization) }
          let(:intake) { create(:intake, vita_partner: organization, client: client) }

          it "cannot manage any client data" do
            expect(subject.can?(:manage, Client)).to eq false
            expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq false
            expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq false
            expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq false
            expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq false
            expect(subject.can?(:manage, User)).to eq false
            expect(subject.can?(:manage, Note.new(client: client))).to eq false
            expect(subject.can?(:manage, VitaPartner.new)).to eq false
            expect(subject.can?(:manage, SystemNote.new)).to eq false
          end
        end

        context "a user with a nil role" do
          let(:user) { build(:user, role_type: nil, role_id: nil) }
          let(:organization) { create :organization }
          let(:client) { create(:client, vita_partner: organization) }
          let(:intake) { create(:intake, vita_partner: organization, client: client) }

          it "cannot manage any client data" do
            expect(subject.can?(:manage, Client)).to eq false
            expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq false
            expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq false
            expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq false
            expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq false
            expect(subject.can?(:manage, User)).to eq false
            expect(subject.can?(:manage, Note.new(client: client))).to eq false
            expect(subject.can?(:manage, VitaPartner.new)).to eq false
            expect(subject.can?(:manage, SystemNote.new)).to eq false
          end
        end
      end
    end

    context "Permissions regarding Coalitions" do
      context "as a coalition lead" do
        let(:coalition) { create :coalition }
        let(:user) { create :coalition_lead_user, coalition: coalition }
        let(:inaccessible_coalition) { create :coalition }

        it "allows read access on your coalition" do
          expect(subject.can?(:read, Coalition)).to eq true
          expect(subject.can?(:read, coalition)).to eq true
        end

        it "does not allow read access on other coalitions" do
          expect(subject.can?(:read, inaccessible_coalition)).to eq false
        end
      end
    end

    context "Permissions regarding Users" do
      context "Managing users" do
        shared_examples :user_cannot_manage_other_users_in_their_site do
          let(:target_user) { create :site_coordinator_user }
          before do
            allow(user).to receive(:accessible_vita_partners).and_return(VitaPartner.where(id: target_user.role.site))
          end

          it "cannot manage other users in a site they have access to" do
            expect(subject.can?(:manage, target_user)).to eq false
          end
        end

        shared_examples :user_can_manage_themselves do
          it "can manage themselves" do
            expect(subject.can?(:manage, user)).to eq true
          end
        end

        context "users with valid non-admin roles" do
          context "a coalition lead" do
            let(:user) { create :coalition_lead_user }

            it_behaves_like :user_can_manage_themselves

            context "users in their coalition" do
              let!(:target_user) do
                create :site_coordinator_user,
                       site: create(:site, parent_organization: create(:organization, coalition: user.role.coalition))
              end

              it "can manage users in their coalition" do
                expect(subject.can?(:manage, target_user)).to eq true
              end
            end

            context "users outside their coalition" do
              let!(:target_user) { create :site_coordinator_user }

              it "cannot manage users outside their coalition" do
                expect(subject.can?(:manage, target_user)).to eq false
              end
            end
          end

          context "an organization lead" do
            let(:user) { create :organization_lead_user }

            it_behaves_like :user_can_manage_themselves

            context "users in their org" do
              let!(:target_user) do
                create :site_coordinator_user,
                       site: create(:site, parent_organization: user.role.organization)
              end

              it "can manage users in their org" do
                expect(subject.can?(:manage, target_user)).to eq true
              end
            end

            context "users outside their org" do
              let!(:target_user) { create :site_coordinator_user }

              it "cannot manage users outside their org" do
                expect(subject.can?(:manage, target_user)).to eq false
              end
            end
          end

          context "a site coordinator" do
            let(:user) { create :site_coordinator_user }

            it_behaves_like :user_can_manage_themselves
            it_behaves_like :user_cannot_manage_other_users_in_their_site
          end

          context "a team member" do
            let(:user) { create :team_member_user }

            it_behaves_like :user_can_manage_themselves
            it_behaves_like :user_cannot_manage_other_users_in_their_site
          end
        end
      end

      context "Viewing users" do
        let(:user) { create :team_member_user } # role is arbitrary in this test
        let(:other_user) { create :team_member_user }
        let(:inaccessible_user) { create :team_member_user }
        before do
          allow(user).to receive(:accessible_users).and_return([user, other_user])
        end

        it "allows read permission on all users returned by accessible_users" do
          expect(subject.can?(:read, user)).to eq true
          expect(subject.can?(:read, other_user)).to eq true
        end

        it "does not allow read permission on users that are not returned by accessible_users" do
          expect(subject.can?(:read, inaccessible_user)).to eq false
        end
      end
    end

    context "Permissions regarding Role objects" do
      context "AdminRole" do
        let(:target_role) { AdminRole }

        context "current user is an admin" do
          let(:user) { create(:admin_user) }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "anyone else" do
          let(:user) { create(:coalition_lead_user) }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end
      end

      context "CoalitionLeadRole" do
        let(:target_role) { create :coalition_lead_role }
        let(:coalition) { target_role.coalition }

        context "current user is coalition lead in the same coalition" do
          let(:user) { create :coalition_lead_user, coalition: coalition }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is coalition lead in a different coalition" do
          let(:user) { create :coalition_lead_user }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "anyone else" do
          let(:user) { create :organization_lead_user, organization: build(:organization, coalition: coalition) }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end
      end

      context "OrganizationLeadRole" do
        let(:target_role) { create :organization_lead_role }
        let(:organization) { target_role.organization }

        context "current user is coalition lead in a parent coalition" do
          let(:coalition) { create :coalition, organizations: [organization] }
          let(:user) { create :coalition_lead_user, coalition: coalition }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is coalition lead in a different coalition" do
          let(:user) { create :coalition_lead_user }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "current user is organization lead in the same organization" do
          let(:user) { create :organization_lead_user, organization: organization }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is organization lead in another organization" do
          let(:user) { create :organization_lead_user }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "anyone else" do
          let(:user) { create :site_coordinator_user, site: create(:site, parent_organization: organization) }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end
      end

      context "SiteCoordinatorRole" do
        let(:coalition) { create :coalition }
        let(:organization) { create :organization, coalition: coalition }
        let(:another_organization) { create :organization, coalition: coalition }
        let(:site) { create(:site, parent_organization: organization) }
        let(:another_site) { create(:site, parent_organization: organization)}
        let(:target_role) { create :site_coordinator_role, site: site }

        context "current user is coalition lead in the site's coalition" do
          let(:user) { create :coalition_lead_user, coalition: coalition }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is coalition lead in a different coalition" do
          let(:user) { create :coalition_lead_user }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "current user is organization lead in the site's parent organization" do
          let(:user) { create :organization_lead_user, organization: organization }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is organization lead in another organization" do
          let(:user) { create :organization_lead_user, organization: another_organization }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "current user is site coordinator in the same site" do
          let(:user) { create :site_coordinator_user, site: site }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is site coordinator in another site" do
          let(:user) { create :site_coordinator_user, site: another_site }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "anyone else" do
          let(:user) { create :team_member_user, site: site }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end
      end

      context "TeamMemberRole" do
        let(:coalition) { create :coalition }
        let(:organization) { create :organization, coalition: coalition }
        let(:another_organization) { create :organization, coalition: coalition }
        let(:site) { create(:site, parent_organization: organization) }
        let(:another_site) { create(:site, parent_organization: organization)}
        let(:target_role) { create :team_member_role, site: site }

        context "current user is coalition lead in the site's coalition" do
          let(:user) { create :coalition_lead_user, coalition: coalition }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is coalition lead in a different coalition" do
          let(:user) { create :coalition_lead_user }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "current user is organization lead in the site's parent organization" do
          let(:user) { create :organization_lead_user, organization: organization }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is organization lead in another organization" do
          let(:user) { create :organization_lead_user, organization: another_organization }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "current user is site coordinator in the same site" do
          let(:user) { create :site_coordinator_user, site: site }

          it "can manage" do
            expect(subject.can?(:manage, target_role)).to eq true
          end
        end

        context "current user is site coordinator in another site" do
          let(:user) { create :site_coordinator_user, site: another_site }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end

        context "anyone else" do
          let(:user) { create :team_member_user, site: site }

          it "cannot manage" do
            expect(subject.can?(:manage, target_role)).to eq false
          end
        end
      end
    end
  end
end
