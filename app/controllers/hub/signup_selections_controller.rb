require 'csv'

module Hub
  class SignupSelectionsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :set_main_heading, only: [:index, :create]
    load_and_authorize_resource :signup_selection, parent: false

    layout "hub"

    def index
      @signup_selection = SignupSelection.new
    end

    def create
      upload = params.require(:signup_selection).dig(:upload)
      id_array =
        begin
          io = upload.tempfile
          io.seek(0)
          io.set_encoding_by_bom
          parsed = CSV.parse(io, headers: true)
          raise StandardError if parsed.headers != ["id"]

          parsed.map { |row| row['id'] }
        rescue StandardError
          @signup_selection.errors.add :upload, "Invalid CSV"
          render :index and return
        end
      @signup_selection = SignupSelection.new(create_params.merge(id_array: id_array, filename: upload.original_filename))

      if @signup_selection.save
        redirect_to action: :index
      else
        render :index
      end
    end

    private

    def create_params
      params.require(:signup_selection).permit(:signup_type).merge(user: current_user)
    end

    def set_main_heading
      @main_heading = "Bulk messages to signups"
    end
  end
end
