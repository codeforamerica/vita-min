module Questions
  class EmailAddressController < QuestionsController
    include AnonymousIntakeConcern
  end
end
