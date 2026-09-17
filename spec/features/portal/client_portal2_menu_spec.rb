require "rails_helper"

RSpec.feature "the client portal (portal2) navigation menu" do
  let(:client) do
    create :client,
           intake: (build :intake, preferred_name: "Randall"),
           tax_returns: [build(:tax_return, :intake_in_progress, year: 2019)]
  end

  before { login_as client, scope: :client }

  context "when the client_portal_improvements flag is enabled" do
    before { Flipper.enable(:client_portal_improvements) }
    after { Flipper.disable(:client_portal_improvements) }

    scenario "the menu renders with all navigation items" do
      visit portal_portal2_path

      expect(page).to have_selector('[data-component="Portal2MenuTrigger"]', text: I18n.t("general.menu"))
      expect(page).to have_selector('[data-component="Portal2MenuCloser"]')
      expect(page).to have_selector('[data-component="Portal2Menu"]')

      within '[data-component="Portal2Menu"]' do
        expect(page).to have_link(I18n.t("portal.shared.portal2_menu.home"), href: portal_portal2_path)
        expect(page).to have_link(I18n.t("portal.shared.portal2_menu.messages"), href: new_portal_message_path)
        expect(page).to have_link(I18n.t("portal.shared.portal2_menu.documents"), href: portal_overview_documents_path)
        expect(page).to have_link(I18n.t("portal.shared.portal2_menu.tax_returns"), href: portal_tax_returns_path)
        expect(page).to have_link(I18n.t("portal.shared.portal2_menu.settings"), href: portal_settings_path)
      end
    end

    scenario "each item carries the Mixpanel menu_click property" do
      visit portal_portal2_path

      {
        "home" => I18n.t("portal.shared.portal2_menu.home"),
        "messages" => I18n.t("portal.shared.portal2_menu.messages"),
        "documents" => I18n.t("portal.shared.portal2_menu.documents"),
        "tax returns" => I18n.t("portal.shared.portal2_menu.tax_returns"),
        "settings" => I18n.t("portal.shared.portal2_menu.settings"),
      }.each do |menu_click, label|
        expect(page).to have_selector(%(a[data-portal2-menu-item="#{menu_click}"]), text: label)
      end
    end

    scenario "the menu is reachable from every portal page" do
      visit portal_overview_documents_path
      expect(page).to have_selector('[data-component="Portal2MenuTrigger"]')

      visit new_portal_message_path
      expect(page).to have_selector('[data-component="Portal2MenuTrigger"]')

      visit portal_tax_returns_path
      expect(page).to have_selector('[data-component="Portal2MenuTrigger"]')

      visit portal_settings_path
      expect(page).to have_selector('[data-component="Portal2MenuTrigger"]')
    end

    context "with javascript", js: true do
      scenario "the menu opens from the Menu button and closes from the X button" do
        visit portal_portal2_path

        expect(page).not_to have_selector('[data-component="Portal2Menu"].open')

        find('[data-component="Portal2MenuTrigger"]').click

        expect(page).to have_selector('[data-component="Portal2Menu"].open')
        expect(page).to have_selector('[data-component="Portal2MenuTrigger"][aria-expanded="true"]', visible: :all)

        find('[data-component="Portal2MenuCloser"]').click

        expect(page).not_to have_selector('[data-component="Portal2Menu"].open')
        expect(page).to have_selector('[data-component="Portal2MenuTrigger"][aria-expanded="false"]')
      end

      scenario "each item navigates to the correct screen" do
        visit portal_portal2_path

        find('[data-component="Portal2MenuTrigger"]').click
        click_on I18n.t("portal.shared.portal2_menu.documents")
        expect(page).to have_current_path(portal_overview_documents_path)

        find('[data-component="Portal2MenuTrigger"]').click
        click_on I18n.t("portal.shared.portal2_menu.messages")
        expect(page).to have_current_path(new_portal_message_path)

        find('[data-component="Portal2MenuTrigger"]').click
        click_on I18n.t("portal.shared.portal2_menu.tax_returns")
        expect(page).to have_current_path(portal_tax_returns_path)

        find('[data-component="Portal2MenuTrigger"]').click
        click_on I18n.t("portal.shared.portal2_menu.settings")
        expect(page).to have_current_path(portal_settings_path)

        find('[data-component="Portal2MenuTrigger"]').click
        click_on I18n.t("portal.shared.portal2_menu.home")
        expect(page).to have_current_path(portal_portal2_path)
      end
    end
  end

  context "when the client_portal_improvements flag is disabled" do
    before { Flipper.disable(:client_portal_improvements) }

    scenario "the portal2 menu is not rendered" do
      visit portal_root_path

      expect(page).not_to have_selector('[data-component="Portal2Menu"]')
      expect(page).not_to have_selector('[data-component="Portal2MenuTrigger"]')
    end
  end
end
