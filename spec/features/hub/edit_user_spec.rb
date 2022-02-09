require "rails_helper"

RSpec.describe "a user editing a user" do
  context "as an authenticated user" do
    context "as an admin" do
      let(:current_user) { create :admin_user }
      let(:user_to_edit) { create :user }
      before { login_as current_user }

      scenario "update all fields" do
        visit edit_hub_user_path(id: user_to_edit.id)
        expect(page).to have_text user_to_edit.name

        fill_in "Name", with: "Nathan Namely"
        fill_in "Phone number", with: "(415) 553-7865"

        click_on "Save"

        expect(page).to have_text "Changes saved"

        expect(page).to have_text("Nathan Namely")
        expect(page).to have_selector("input[value='+14155537865']")
      end

      scenario "resending invitations" do
        visit edit_hub_user_path(id: user_to_edit.id)

        click_on "Resend invitation email"

        within(".flash--notice") do
          expect(page).to have_text "Invitation re-sent to #{user_to_edit.email}"
        end

        mail = ActionMailer::Base.deliveries.last
        html_body = mail.body.parts[1].decoded
        accept_invite_url = Nokogiri::HTML.parse(html_body).at_css("a")["href"]
        expect(mail.subject).to eq "You've been invited to GetYourRefund"
        expect(accept_invite_url).to be_present
        expect(mail.body.encoded).to have_text "Hello,"
        expect(mail.body.encoded).to have_text "#{current_user.name} (#{current_user.email}) has invited #{user_to_edit.name} to create an account on GetYourRefund"
        expect(mail.body.encoded).to have_text "If you don't want to accept the invitation, please ignore this email."
      end

      scenario "deleting a user" do
        create(:tax_return, assigned_user: user_to_edit) # ensure soft delete

        visit edit_hub_user_path(id: user_to_edit)
        click_on "Delete"

        expect(page).to have_current_path(hub_users_path)
        expect(page).to have_text("Suspended #{user_to_edit.name}")

        within "#user-#{user_to_edit.id}" do
          expect(page).to have_text("Suspended")
        end
      end

      context "editing user roles" do
        scenario "assigning an admin role" do
          user_to_edit = create(:coalition_lead_user)

          visit edit_hub_user_path(id: user_to_edit)
          click_on "Admin"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Admin"
          end
        end

        scenario "assigning a client success role" do
          user_to_edit = create(:coalition_lead_user)

          visit edit_hub_user_path(id: user_to_edit)
          click_on "Client Success"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Client Success"
          end
        end

        context "assigning to a greeter role" do
          scenario "editing an admin user to be a greeter" do
            user_to_edit = create(:admin_user)

            visit edit_hub_user_path(id: user_to_edit)
            click_on "Greeter"
            click_on "Submit"

            within "#current-role" do
              expect(page).to have_text "Greeter"
            end
          end
        end

        scenario "assigning a coalition lead role" do
          user_to_edit = create(:admin_user)
          create :coalition, name: "Koala Koalition"
          create :coalition, name: "Coal Coalition"

          visit edit_hub_user_path(id: user_to_edit)
          click_on "Coalition Lead"

          expect(page).to have_text("Coal Coalition")

          select "Koala Koalition"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Coalition Lead, Koala Koalition"
          end
        end

        scenario "assigning a organization lead role" do
          create :organization, name: "Orange Organization"
          create :organization, name: "Odious Organization"

          visit edit_hub_user_path(id: user_to_edit)
          click_on "Organization Lead"

          expect(page).to have_text("Odious Organization")

          select "Orange Organization"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Organization Lead, Orange Organization"
          end
        end

        scenario "assigning a site coordinator role" do
          user_to_edit = create(:admin_user)
          create :site, name: "Suite Site"
          create :site, name: "Sour Site"

          visit edit_hub_user_path(id: user_to_edit)
          click_on "Site Coordinator"

          expect(page).to have_text("Sour Site")

          select "Suite Site"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Site Coordinator, Suite Site"
          end
        end

        scenario "assigning a team member role" do
          user_to_edit = create(:admin_user)
          create :site, name: "Suite Site"
          create :site, name: "Sour Site"

          visit edit_hub_user_path(id: user_to_edit)
          click_on "Team Member"

          expect(page).to have_text("Sour Site")

          select "Suite Site"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Team Member, Suite Site"
          end
        end
      end
    end

    context "as an coalition lead" do
      let(:current_user) { create :coalition_lead_user, coalition: coalition }
      let(:coalition) { create(:coalition, name: "Koala Coalition") }

      context "editing a user in my coalition" do
        let(:organization) { create :organization, coalition: coalition, name: "Apples Associated" }
        let(:user_to_edit) { create :organization_lead_user, organization: organization }
        before { login_as current_user }

        scenario "update all fields" do
          visit edit_hub_user_path(id: user_to_edit.id)
          expect(page).to have_text user_to_edit.name

          fill_in "Name", with: "Nathan Namely"
          fill_in "Phone number", with: "(415) 553-7865"

          click_on "Save"

          expect(page).to have_text "Changes saved"

          expect(page).to have_text("Nathan Namely")
          expect(page).to have_selector("input[value='+14155537865']")
        end

        context "editing user roles" do
          scenario "assigning a coalition lead role" do
            visit edit_hub_user_path(id: user_to_edit)
            click_on "Coalition Lead"

            expect(page).to have_text("Koala Coalition")

            select "Koala Coalition"

            click_on "Submit"

            within "#current-role" do
              expect(page).to have_text "Coalition Lead, Koala Coalition"
            end
          end

          scenario "assigning a organization lead role on a different org" do
            create :organization, name: "Orange Organization", coalition: coalition

            visit edit_hub_user_path(id: user_to_edit)
            click_on "Organization Lead"

            expect(page).to have_text("Apples Associated")

            select "Orange Organization"

            click_on "Submit"

            within "#current-role" do
              expect(page).to have_text "Organization Lead, Orange Organization"
            end
          end

          scenario "assigning a site coordinator role" do
            create :site, name: "Sweet Site", parent_organization: organization
            create :site, name: "Sour Site", parent_organization: organization

            visit edit_hub_user_path(id: user_to_edit)
            click_on "Site Coordinator"

            expect(page).to have_text("Sour Site")

            select "Sweet Site"

            click_on "Submit"

            within "#current-role" do
              expect(page).to have_text "Site Coordinator, Sweet Site"
            end
          end

          scenario "assigning a team member role" do
            create :site, name: "Sweet Site", parent_organization: organization
            create :site, name: "Sour Site", parent_organization: organization

            visit edit_hub_user_path(id: user_to_edit)
            click_on "Team Member"

            expect(page).to have_text("Sour Site")

            select "Sweet Site"

            click_on "Submit"

            within "#current-role" do
              expect(page).to have_text "Team Member, Sweet Site"
            end
          end
        end
      end
    end

    context "as an organization lead" do
      let(:organization) { create :organization, name: "Apples Associated" }
      let(:current_user) { create :organization_lead_user, organization: organization }

      context "editing a user in my organization" do
        let(:site) { create :site, parent_organization: organization, name: "Sweet Site" }
        let(:user_to_edit) { create :site_coordinator_user, site: site }
        before { login_as current_user }

        scenario "update all fields" do
          visit edit_hub_user_path(id: user_to_edit.id)
          expect(page).to have_text user_to_edit.name

          fill_in "Name", with: "Nathan Namely"
          fill_in "Phone number", with: "(415) 553-7865"

          click_on "Save"

          expect(page).to have_text "Changes saved"

          expect(page).to have_text("Nathan Namely")
          expect(page).to have_selector("input[value='+14155537865']")
        end

        context "editing user roles" do
          scenario "assigning a organization lead role" do
            visit edit_hub_user_path(id: user_to_edit)
            click_on "Organization Lead"

            expect(page).to have_text("Apples Associated")

            select "Apples Associated"

            click_on "Submit"

            within "#current-role" do
              expect(page).to have_text "Organization Lead, Apples Associated"
            end
          end

          scenario "assigning a site coordinator role on a different site" do
            create :site, name: "Sour Site", parent_organization: organization

            visit edit_hub_user_path(id: user_to_edit)
            click_on "Site Coordinator"

            expect(page).to have_text("Sweet Site")

            select "Sour Site"

            click_on "Submit"

            within "#current-role" do
              expect(page).to have_text "Site Coordinator, Sour Site"
            end
          end

          scenario "assigning a team member role" do
            create :site, name: "Sour Site", parent_organization: organization

            visit edit_hub_user_path(id: user_to_edit)
            click_on "Team Member"

            expect(page).to have_text("Sour Site")

            select "Sweet Site"

            click_on "Submit"

            within "#current-role" do
              expect(page).to have_text "Team Member, Sweet Site"
            end
          end
        end
      end
    end
  end
end
