module Hub::StateFile
  class IntakeTransitionController < Hub::StateFile::BaseController

    def index
      @us_state = params[:us_state]
      if @us_state.blank?
        @us_state = StateFile::StateInformationService.active_state_codes.first
        redirect_to params.merge(us_state: @us_state).permit(:us_state)
        return
      end
      intake_class = StateFile::StateInformationService.intake_class(@us_state)
      @intakes = intake_class.all.paginate(page: params[:page], per_page: 30)
    end

    def update
      puts "TODO: Do update"
      redirect_to :index
    end
  end
end