module Hub
  class BulkMessageCsvsController < ApplicationController
    include FilesConcern
    include AccessControllable
    before_action :require_sign_in
    helper_method :transient_storage_url
    load_and_authorize_resource

    layout "hub"

    def index
      @main_heading = "Bulk messaging CSVs"
    end

    def create
      if @bulk_message_csv.valid?
        @bulk_message_csv.save
        BulkAction::MessageCsvImportJob.perform_later(@bulk_message_csv)
      end
      redirect_to action: :index
    end

    private

    def create_params
      params.require(:bulk_message_csv).permit(:upload).merge(user: current_user, status: :queued)
    end
  end
end
