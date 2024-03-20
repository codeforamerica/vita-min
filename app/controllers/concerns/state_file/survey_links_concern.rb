module StateFile
  module SurveyLinksConcern
    extend ActiveSupport::Concern
    def survey_link(intake)
      case intake.state_code
      when 'ny'
        'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3pXUfy2c3SScmgu'
      when 'az'
        'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey'
      else
        ''
      end
    end
  end
end
