module Questions
  class EligibilityHouseholdController < QuestionsController
    include AnonymousIntakeConcern

    layout "intake"

    def next_path
      TriageResultService.new(current_intake).after_household_triaged_route || super
    end

    def illustration_path; end

    private

    def allow_other_host_redirect?(destination)
      destination_uri = URI.parse(destination)
      simple_file_uri = URI.parse(Rails.configuration.simple_file_url)
      destination_uri.host == simple_file_uri.host && destination_uri.scheme == simple_file_uri.scheme
    rescue URI::InvalidURIError
      false
    end
  end
end