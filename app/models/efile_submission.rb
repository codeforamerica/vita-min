# == Schema Information
#
# Table name: efile_submissions
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  irs_submission_id :string
#  tax_return_id     :bigint
#
# Indexes
#
#  index_efile_submissions_on_tax_return_id  (tax_return_id)
#
class EfileSubmission < ApplicationRecord
  belongs_to :tax_return
  has_one :intake, through: :tax_return
  has_one :client, through: :tax_return
  has_many :dependents, through: :intake
  has_one :address, as: :record
  has_many :efile_submission_transitions, class_name: "EfileSubmissionTransition", autosave: false, dependent: :destroy
  has_one_attached :submission_bundle

  before_validation :generate_irs_submission_id
  validates_format_of :irs_submission_id, with: /\A[0-9]{6}[0-9]{7}[0-9a-z]{7}\z/
  validates_presence_of :irs_submission_id
  validates_uniqueness_of :irs_submission_id

  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: EfileSubmissionTransition,
    initial_state: EfileSubmissionStateMachine.initial_state,
  ]

  scope :most_recent_by_tax_return, lambda {
    joins(:tax_return).where("efile_submissions.id = (SELECT MAX(efile_submissions.id) FROM efile_submissions WHERE efile_submissions.tax_return_id = tax_returns.id)")
  }

  def state_machine
    @state_machine ||= EfileSubmissionStateMachine.new(self, transition_class: EfileSubmissionTransition)
  end

  delegate :can_transition_to?, :current_state, :history, :last_transition, :last_transition_to,
           :transition_to!, :transition_to, :in_state?, to: :state_machine

  # If a federal tax return is rejected for a dependent SSN/Name Control mismatch,
  # the return can be re-transmitted and accepted by the IRS if the Imperfect Return Election is made.
  # This election can only be made if the original return rejected with reject code SEIC-F1040-501-02 or R0000-504-02.
  # (Placeholder for implementation logic)
  def imperfect_return_resubmission?
    false
  end

  def resubmission?
    previously_transmitted_submission.present?
  end

  def previously_transmitted_submission
    transition = last_transition_to("preparing")
    return unless transition.present?

    previous_submission_id = transition.metadata["previous_submission_id"]
    EfileSubmission.find(previous_submission_id) if previous_submission_id.present?
  end

  def generate_irs_address
    address_service = StandardizeAddressService.new(intake)
    if address_service.valid?
      attrs = {
        zip_code: address_service.zip_code,
        street_address: address_service.street_address,
        state: address_service.state,
        city: address_service.city
      }
    end
    address.present? ? address.update(attrs) : create_address(attrs)
    address_service
  end

  def generate_form_1040_pdf
    filename = "IRS 1040 - TY #{tax_return.year} - #{irs_submission_id}.pdf"

    client.documents.create!(
      document_type: DocumentTypes::Form1040.key,
      display_name: filename,
      upload: {
        io: AdvCtcIrs1040Pdf.new(self).output_file,
        filename: filename,
        content_type: "application/pdf",
        identify: false
      },
      tax_return: tax_return
    )
  end

  private

  def generate_irs_submission_id(i = 0)
    return if self.irs_submission_id.present?

    raise "Max irs_submission_id attempts exceeded. Too many submissions today?" if i > 5

    efin = EnvironmentCredentials.dig(:irs, :efin)
    irs_submission_id = "#{efin}#{Date.current.strftime('%C%y%j')}#{SecureRandom.base36(7)}"
    if self.class.find_by(irs_submission_id: irs_submission_id)
      i += 1
      generate_irs_submission_id(i)
    else
      self.irs_submission_id = irs_submission_id
    end
  end
end
