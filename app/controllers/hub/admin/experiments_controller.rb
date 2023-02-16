module Hub
  module Admin
    class ExperimentsController < ApplicationController
      include AccessControllable
      before_action :require_sign_in
      load_and_authorize_resource
      layout "hub"

      def index
        @experiments = Experiment.all
        @experiment_participants = ExperimentParticipant.all
      end
    end
  end
end
