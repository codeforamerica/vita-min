require "rails_helper"

RSpec.describe "a user editing a user" do
  context "as an authenticated user" do
    context "as an admin" do
      let(:current_user) { create :admin_user }
      let(:user_to_edit) { create :user }
      before { login_as current_user }

      scenario "navigation", js: true, screenshot: true do
        screenshot_after do
          visit edit_hub_user_path(id: user_to_edit.id)
        end
        click_on "Cancel"

        screenshot_after do
          expect(page).to have_current_path(hub_users_path)
        end
        click_on "Return to Profile"

        screenshot_after do
          expect(page).to have_current_path(hub_user_profile_path)
        end
        click_on "Return to Dashboard"

        screenshot_after do
          expect(page).to have_current_path(hub_assigned_clients_path)
        end
      end

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
          click_on "Client success"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Client success"
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
          click_on "Coalition lead"

          expect(page).to have_text("Coal Coalition")

          select "Koala Koalition"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Coalition lead, Koala Koalition"
          end
        end

        scenario "assigning a organization lead role" do
          create :organization, name: "Orange Organization"
          create :organization, name: "Odious Organization"

          visit edit_hub_user_path(id: user_to_edit)
          click_on "Organization lead"

          expect(page).to have_text("Odious Organization")

          select "Orange Organization"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Organization lead, Orange Organization"
          end
        end

        scenario "assigning a site coordinator role" do
          user_to_edit = create(:admin_user)
          create :site, name: "Suite Site"
          create :site, name: "Sour Site"

          visit edit_hub_user_path(id: user_to_edit)
          click_on "Site coordinator"

          expect(page).to have_text("Sour Site")

          select "Suite Site"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Site coordinator, Suite Site"
          end
        end

        scenario "assigning a team member role" do
          user_to_edit = create(:admin_user)
          create :site, name: "Suite Site"
          create :site, name: "Sour Site"

          visit edit_hub_user_path(id: user_to_edit)
          click_on "Team member"

          expect(page).to have_text("Sour Site")

          select "Suite Site"

          click_on "Submit"

          within "#current-role" do
            expect(page).to have_text "Team member, Suite Site"
          end
        end
      end
    end
  end
end
