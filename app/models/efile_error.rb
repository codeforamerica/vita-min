# == Schema Information
#
# Table name: efile_errors
#
#  id              :bigint           not null, primary key
#  auto_cancel     :boolean          default(FALSE)
#  auto_wait       :boolean          default(FALSE)
#  category        :string
#  code            :string
#  correction_path :string
#  expose          :boolean          default(FALSE)
#  message         :text
#  service_type    :integer          default("unfilled"), not null
#  severity        :string
#  source          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class EfileError < ApplicationRecord
  has_rich_text :description_en
  has_rich_text :description_es
  has_rich_text :resolution_en
  has_rich_text :resolution_es

  enum service_type: { unfilled: 0, ctc: 1, state_file: 2 }, _prefix: :service_type

  def self.error_codes_to_retry_once
    # These error codes indicate that the IRS had trouble parsing our data. When we see this, it
    # is usually correlated with IRS downtime. The implication seems to be that the IRS didn't process
    # our submission correctly during the downtime period, and that re-submitting is a good idea.
    %w[X0000-010 X0000-032]
  end

  def description(locale)
    case locale
    when :en
      description_en
    when :es
      description_es.present? ? description_es : description_en
    end
  end

  def resolution(locale)
    case locale
    when :en
      resolution_en
    when :es
      resolution_es.present? ? resolution_es : resolution_en
    end
  end

  def data_source
    # This feels insanely complex - maybe we need to set up has_many relations...
    return @data_source if @data_source.present?
    transition_ids = EfileSubmissionTransitionError.where(efile_error_id: id).pluck(:efile_submission_transition_id)
    submission_ids = EfileSubmissionTransition.where(id: transition_ids).pluck(:efile_submission_id)
    submission = EfileSubmission.find(submission_ids.last)
    @data_source = submission.data_source
  end

  def default_correction_path
    data_source = self.data_source
    c = StateFile::Questions::NameDobController
    c.to_path_helper(action: c.navigation_actions.first, us_state: data_source.state_code, locale: data_source.locale || "en")
  end
end
