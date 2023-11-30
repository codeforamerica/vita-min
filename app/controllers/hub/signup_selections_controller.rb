require 'csv'

module Hub
  class SignupSelectionsController < Hub::BaseController
    before_action :set_main_heading, only: [:index, :create]
    load_and_authorize_resource

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
      signup_model = create_params[:signup_type] == "GYR" ? Signup : CtcSignup
      validated_ids = signup_model.where(id: id_array).pluck(:id)
      @signup_selection = SignupSelection.new(create_params.merge(id_array: validated_ids, filename: upload.original_filename))

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
