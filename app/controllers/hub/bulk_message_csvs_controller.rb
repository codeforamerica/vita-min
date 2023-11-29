module Hub
  class BulkMessageCsvsController < Hub::BaseController
    load_and_authorize_resource
    before_action :load_bulk_message_csvs

    layout "hub"

    def index
      @main_heading = "Bulk messaging CSVs"
      @bulk_message_csv = BulkMessageCsv.new
    end

    def create
      if @bulk_message_csv.valid?
        @bulk_message_csv.save
        BulkAction::MessageCsvImportJob.perform_later(@bulk_message_csv)
        redirect_to action: :index
      else
        render :index
      end
    end

    private

    def load_bulk_message_csvs
      @bulk_message_csvs = BulkMessageCsv.all.order(id: :desc)
    end

    def create_params
      params.require(:bulk_message_csv).permit(:upload).merge(user: current_user, status: :queued)
    end
  end
end
