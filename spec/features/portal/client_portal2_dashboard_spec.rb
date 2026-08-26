require "rails_helper"

RSpec.feature 'client in the portal' do
  context 'tax return state' do
    let(:client) do
      create :client,
        intake: (build :intake, preferred_name: 'Gertrude', completed_at: DateTime.current),
        tax_returns: [build(:tax_return, year: 2019)]
    end
    before do
      login_as client, scope: :client
      Flipper.enable(:client_portal_improvements)
    end

    #####################
    ## Intake statuses ##
    #####################

    scenario 'with return status :intake_in_progress' do
      client.tax_returns.last.transition_to!(:intake_in_progress)
      client.intake.current_step = Questions::AssetSaleLossController.to_path_helper
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'You\'re still filling out your tax form.'
      expect(page).to have_link 'Complete tax questions', href: Questions::AssetSaleLossController.to_path_helper
    end

    scenario 'with return status :intake_needs_doc_help' do
      client.tax_returns.last.transition_to!(:intake_needs_doc_help)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'You\'re still filling out your tax form.'
      expect(page).to have_link 'Complete tax questions', href: Portal::UploadDocumentsController.to_path_helper(action: :index)
    end

    scenario 'with return status :intake_info_requested' do
      client.tax_returns.last.transition_to!(:intake_info_requested)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'We need a few more documents to finish your tax return.'
      expect(page).to have_link 'Add documents', href: Portal::UploadDocumentsController.to_path_helper(action: :index)
    end

    scenario 'with return status :intake_greeter_info_requested' do
      client.tax_returns.last.transition_to!(:intake_greeter_info_requested)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'We need a few more documents to finish your tax return.'
      expect(page).to have_link 'Add documents', href: Portal::UploadDocumentsController.to_path_helper(action: :index)
    end

    scenario 'with return status :intake_ready' do
      client.tax_returns.last.transition_to!(:intake_ready)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'Your tax team is reviewing your information.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :intake_reviewing' do
      client.tax_returns.last.transition_to!(:intake_reviewing)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'Your tax team is reviewing your information.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :intake_ready_for_call' do
      client.tax_returns.last.transition_to!(:intake_ready_for_call)
      visit '/portal/portal2'

      expect(page).to have_text 'In progress'
      expect(page).to have_text 'Your tax team is reviewing your information.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    ###################
    ## Prep statuses ##
    ###################

    scenario 'with return status :prep_ready_for_prep' do
      client.tax_returns.last.transition_to!(:prep_ready_for_prep)
      visit '/portal/portal2'

      expect(page).to have_text 'Tax prep'
      expect(page).to have_text 'Your tax team is preparing your return.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :prep_preparing' do
      client.tax_returns.last.transition_to!(:prep_preparing)
      visit '/portal/portal2'

      expect(page).to have_text 'Tax prep'
      expect(page).to have_text 'Your tax team is preparing your return.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :prep_info_requested' do
      client.tax_returns.last.transition_to!(:prep_info_requested)
      allow_any_instance_of(TaxReturnCardHelper).to receive(:contact_method_of_last_tax_team_message).
        with(client.intake).
        and_return('email')
      visit '/portal/portal2'

      expect(page).to have_text 'Tax prep'
      expect(page).to have_text 'We need more information to prepare your return.'
      # Special test here: check for correct contact method (email, in this case).
      expect(page).to have_text 'Your tax team sent a question via email.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    #####################
    ## Review statuses ##
    #####################

    scenario 'with return status :review_ready_for_qr' do
      client.tax_returns.last.transition_to!(:review_ready_for_qr)
      visit '/portal/portal2'

      expect(page).to have_text 'Final check'
      expect(page).to have_text 'Your return is in final review.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :review_reviewing' do
      client.tax_returns.last.transition_to!(:review_reviewing)
      visit '/portal/portal2'

      expect(page).to have_text 'Final check'
      expect(page).to have_text 'Your return is in final review.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :review_ready_for_call' do
      client.tax_returns.last.transition_to!(:review_ready_for_call)
      visit '/portal/portal2'

      expect(page).to have_text 'Final check'
      expect(page).to have_text 'Your return is in final review.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    # TODO once GYR1-1085 is merged.
    xscenario 'with return status :review_signature_requested' do
      client.tax_returns.last.transition_to!(:review_signature_requested)
      visit '/portal/portal2'

      expect(page).to have_text 'Final check'
      # expect(page).to have_text 'Your return is in final review.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :review_info_requested' do
      client.tax_returns.last.transition_to!(:review_info_requested)
      allow_any_instance_of(TaxReturnCardHelper).to receive(:contact_method_of_last_tax_team_message).
        with(client.intake).
        and_return('email')
      visit '/portal/portal2'

      expect(page).to have_text 'Final check'
      expect(page).to have_text 'Your tax team needs one more thing before finalizing your return.'
      # Special test here: check for correct contact method (email, in this case).
      expect(page).to have_text 'Your tax team sent a question via email.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    ###################
    ## File statuses ##
    ###################

    scenario 'with return status :file_needs_review' do
      client.tax_returns.last.transition_to!(:file_needs_review)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_ready_to_file' do
      client.tax_returns.last.transition_to!(:file_ready_to_file)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_efiled' do
      client.tax_returns.last.transition_to!(:file_efiled)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_mailed' do
      client.tax_returns.last.transition_to!(:file_mailed)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_rejected' do
      client.tax_returns.last.transition_to!(:file_rejected)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_accepted' do
      client.tax_returns.last.transition_to!(:file_accepted)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_not_filing' do
      client.tax_returns.last.transition_to!(:file_not_filing)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_hold' do
      client.tax_returns.last.transition_to!(:file_hold)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end

    scenario 'with return status :file_fraud_hold' do
      client.tax_returns.last.transition_to!(:file_fraud_hold)
      visit '/portal/portal2'

      expect(page).to have_text 'Almost done'
      expect(page).to have_text 'Your return is signed and on its way to the IRS.'
      expect(page).to have_link 'Message tax team', href: new_portal_message_path
    end
  end
end
