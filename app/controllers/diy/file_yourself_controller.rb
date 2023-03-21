module Diy
  class FileYourselfController < BaseController
    def edit
      @form = FileYourselfForm.new
    end

    def update
      diy_intake = current_diy_intake
      @form = FileYourselfForm.new(diy_intake, create_params)
      if @form.valid?
        @form.save
        session[:diy_intake_id] = diy_intake.id
        redirect_to(diy_continue_to_fsa_path)
      else
        render :edit
      end
    end

    private

    def current_diy_intake
      if session[:diy_intake_id]
        DiyIntake.find(session[:diy_intake_id])
      else
        DiyIntake.new(preferred_first_name: "temp")
      end
    end

    def create_params
      form_params = params.fetch(:file_yourself_form, {}).permit(FileYourselfForm.attribute_names)
      if session[:diy_intake_id]
        existing_diy_intake = DiyIntake.find(session[:diy_intake_id])
        form_params.merge(
          source: existing_diy_intake.source,
          referrer: existing_diy_intake.referrer,
          visitor_id: existing_diy_intake.visitor_id,
          locale: existing_diy_intake.locale
        )
      else
        form_params.merge(
          source: source,
          referrer: referrer,
          visitor_id: visitor_id,
          locale: I18n.locale
        )
      end
    end
  end
end
