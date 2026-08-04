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
      visit portal_root_path

      expect(page).to have_selector('[data-component="Portal2MenuTrigger"]', text: I18n.t("general.menu"))
      expect(page).to have_selector('[data-component="Portal2MenuCloser"]')
      expect(page).to have_selector('[data-component="Portal2Menu"]')

      within '[data-component="Portal2Menu"]' do
        expect(page).to have_link(I18n.t("portal.shared.portal2_menu.home"), href: portal_root_path)
        expect(page).to have_link(I18n.t("portal.shared.portal2_menu.messages"), href: new_portal_message_path)
        expect(page).to have_link(I18n.t("portal.shared.portal2_menu.documents"), href: overview_documents_portal_path)
        # Tax returns and Account info are intentionally dead links for now (wired up in later tickets).
        expect(page).to have_link(I18n.t("portal.shared.portal2_menu.tax_returns"), href: "#")
        expect(page).to have_link(I18n.t("portal.shared.portal2_menu.account_info"), href: "#")
      end
    end

    scenario "each item carries the Mixpanel menu_click property" do
      visit portal_root_path

      {
        "home" => I18n.t("portal.shared.portal2_menu.home"),
        "messages" => I18n.t("portal.shared.portal2_menu.messages"),
        "documents" => I18n.t("portal.shared.portal2_menu.documents"),
        "tax returns" => I18n.t("portal.shared.portal2_menu.tax_returns"),
        "settings" => I18n.t("portal.shared.portal2_menu.account_info"),
      }.each do |menu_click, label|
        expect(page).to have_selector(%(a[data-portal2-menu-item="#{menu_click}"]), text: label)
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
