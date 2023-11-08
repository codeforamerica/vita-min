module StateFile
  class AzStateCreditsForm < QuestionsForm
    set_attributes_for :intake, :tribal_member, :tribal_wages, :armed_forces_member, :armed_forces_wages

    validates :tribal_wages, presence: true, allow_blank: false, if: -> { tribal_member == "yes" }
    validates :armed_forces_wages, presence: true, allow_blank: false, if: -> { armed_forces_member == "yes" }

    def save
      attributes_to_save = attributes_for(:intake)
      attributes_to_save[:tribal_wages] = nil if tribal_member == "no"
      attributes_to_save[:armed_forces_wages] = nil if armed_forces_member == "no"
      @intake.update(attributes_to_save)

      # Create submission now so PDF link button can be shown on the next page
      efile_submission = EfileSubmission.create!(
        data_source: @intake,
        )
      if Rails.env.development? || Rails.env.test?
        efile_submission.transition_to(:preparing)
      end
    end
  end
end