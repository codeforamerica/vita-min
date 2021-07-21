module Ctc
  module Questions
    class MailingAddressController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"
    end
  end
end