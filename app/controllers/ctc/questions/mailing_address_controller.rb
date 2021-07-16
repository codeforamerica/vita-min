module Ctc
  module Questions
    class MailingAddressController < QuestionsController
      include AuthenticatedCtcClientConcern
      include AnonymousIntakeConcern

      layout "intake"
    end
  end
end