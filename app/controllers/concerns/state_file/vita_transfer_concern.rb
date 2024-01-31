module StateFile
  module VitaTransferConcern
    # This concern can be used by any controller that needs to link to the
    # VITA Google Form on the offboarding pages
    extend ActiveSupport::Concern

    def vita_link
      case params[:us_state]
      when 'ny'
        'https://airtable.com/appQS3abRZGjT8wII/pagtpLaX0wokBqnuA/form'
      when 'az'
        'https://uwvita.freshdesk.com/support/tickets/new'
      end
    end
  end
end