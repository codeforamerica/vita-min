module Questions
  class ScholarshipsController < QuestionsController
    # temporarily redirect to root until there are more pages
    def next_path
      root_path
    end
  end
end