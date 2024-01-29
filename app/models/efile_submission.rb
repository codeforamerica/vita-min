# == Schema Information
#
# Table name: efile_submissions
#
#  id                      :bigint           not null, primary key
#  claimed_eitc            :boolean
#  data_source_type        :string
#  last_checked_for_ack_at :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  data_source_id          :bigint
#  irs_submission_id       :string
#  tax_return_id           :bigint
#
# Indexes
#
#  index_efile_submissions_on_created_at            (created_at)
#  index_efile_submissions_on_data_source           (data_source_type,data_source_id)
#  index_efile_submissions_on_irs_submission_id     (irs_submission_id)
#  index_efile_submissions_on_tax_return_id         (tax_return_id)
#  index_efile_submissions_on_tax_return_id_and_id  (tax_return_id,id DESC)
#
class EfileSubmission < ApplicationRecord
  belongs_to :tax_return, optional: true
  belongs_to :data_source, polymorphic: true, optional: true
  has_one :intake, through: :tax_return
  has_one :client, through: :tax_return
  has_one :fraud_score, class_name: "Fraud::Score"
  has_many :qualifying_dependents, foreign_key: :efile_submission_id, class_name: "EfileSubmissionDependent"
  has_one :verified_address, as: :record, dependent: :destroy, class_name: "Address"
  has_many :efile_submission_transitions, -> { order(id: :asc) }, class_name: "EfileSubmissionTransition", autosave: false, dependent: :destroy
  has_one_attached :submission_bundle
  validates :irs_submission_id, format: { with: /\A[0-9]{6}[0-9]{7}[0-9a-z]{7}\z/ }, presence: true, uniqueness: true, allow_nil: true

  STATE_INTAKE_CLASS_NAMES = [StateFileAzIntake, StateFileNyIntake].map(&:to_s).freeze

  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: EfileSubmissionTransition,
    initial_state: EfileSubmissionStateMachine.initial_state,
  ]

  scope :most_recent_by_current_year_tax_return, lambda {
    joins(:tax_return).where("efile_submissions.id = (SELECT MAX(efile_submissions.id) FROM efile_submissions
                                WHERE efile_submissions.tax_return_id = tax_returns.id) AND year = ?", MultiTenantService.new(:ctc).current_tax_year)
  }

  scope :for_state_filing, lambda {
    where(data_source_type: STATE_INTAKE_CLASS_NAMES)
  }

  default_scope { order(id: :asc) }

  def tax_year
    return tax_return.year if tax_return
    return data_source.tax_return_year if data_source
  end

  def state_machine
    @state_machine ||= EfileSubmissionStateMachine.new(self, transition_class: EfileSubmissionTransition)
  end

  delegate :can_transition_to?, :current_state, :history, :last_transition, :last_transition_to,
           :transition_to!, :transition_to, :in_state?, to: :state_machine

  def self.state_counts(except: [])
    result = {}
    EfileSubmissionStateMachine.states.each { |state| result[state] = 0 }
    ActiveRecord::Base.connection.execute(<<~SQL).each { |row| result[row['to_state']] = row['count'] }
      SELECT to_state, COUNT(*) FROM "efile_submissions"
      JOIN tax_returns ON ( efile_submissions.tax_return_id = tax_returns.id AND tax_returns.year = #{MultiTenantService.new(:ctc).current_tax_year} )
      LEFT OUTER JOIN efile_submission_transitions AS most_recent_efile_submission_transition ON (
        efile_submissions.id = most_recent_efile_submission_transition.efile_submission_id AND 
        most_recent_efile_submission_transition.most_recent = TRUE
      )
      WHERE most_recent_efile_submission_transition.to_state IS NOT NULL
      GROUP BY to_state
    SQL
    result.except(*except)
  end

  def is_for_federal_filing?
    tax_return.present?
  end

  def is_for_state_filing?
    data_source_type.in?(STATE_INTAKE_CLASS_NAMES)
  end

  # If a federal tax return is rejected for a dependent SSN/Name Control mismatch,
  # the return can be re-transmitted and accepted by the IRS if the Imperfect Return Election is made.
  # This election can only be made if the original return rejected with reject code SEIC-F1040-501-02 or R0000-504-02.
  def imperfect_return_resubmission?
    return false unless previously_transmitted_submission.present?
    
    previously_transmitted_submission.efile_submission_transitions.collect(&:efile_errors).flatten.any? { |error| ["SEIC-F1040-501-02", "R0000-504-02"].include? error.code }
  end

  def accepted_as_imperfect_return?
    current_state == "accepted" && last_transition.metadata.key?("imperfect_return_acceptance")
  end

  def last_client_accessible_transition
    # TODO: Simplify logic here so that we can show appropriate next steps for all cancelled returns
    transitions = history.reverse
    # Allow showing of cancelled state for clients who transitioned from fraud hold
    if transitions[0]&.to_state == "cancelled" && transitions[1]&.to_state == "fraud_hold"
      return transitions[0]
    end

    # We don't show the cancelled status HERE because it hides the instructions
    # for how to handle your reject through cpaper filing.
    transitions.find do |transition|
      !EfileSubmissionStateMachine::CLIENT_INACCESSIBLE_STATUSES.include?(transition.to_state)
    end
  end

  def resubmission?
    previously_transmitted_submission.present?
  end

  def admin_resubmission?
    reference_transition = last_transition_to("preparing")
    reference_transition.present? && reference_transition.initiated_by.present? && reference_transition.initiated_by.admin?
  end

  def first_submission?
    previous_submission_id.nil?
  end

  def previous_submission_id
    transition = last_transition_to("preparing")
    return unless transition.present?

    transition.metadata["previous_submission_id"]
  end

  def previously_transmitted_submission
    previous_submission = EfileSubmission.find(previous_submission_id) if previous_submission_id.present?
    return nil unless previous_submission.present?

    previous_submission if previous_submission.last_transition_to("transmitted").present?
  end

  def source_record
    is_for_state_filing? ? data_source : tax_return
  end

  def generate_verified_address(i = 0)
    # TODO(state-file)
    return OpenStruct.new(valid?: true) unless intake

    return OpenStruct.new(valid?: true) if verified_address.present?

    address_service = StandardizeAddressService.new(intake, read_timeout: 1500)

    if address_service.timeout? && i < 2
      generate_verified_address(i += 1)
    end

    if address_service.valid?
      create_verified_address!(address_service.verified_address_attributes)
    end
    address_service # return the service object so that we can get errors if there are any
  end

  def benefits_eligibility
    Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: qualifying_dependents)
  end

  def pdf_bundle_filename
    slug = irs_submission_id[6..] if irs_submission_id.present?
    filename = "IRS 1040 - TY#{tax_return.year}"
    filename += slug ? " - #{slug}.pdf" : ".pdf"
    filename
  end

  def generate_filing_pdf
    if is_for_federal_filing?
      pdf_documents = SubmissionBuilder::Ty2021::Return1040.new(self).pdf_documents
      output_file = Tempfile.new([pdf_bundle_filename, ".pdf"], "tmp/")
      filled_out_documents = pdf_documents.map { |document| document.pdf.new(self, **document.kwargs).output_file }
      PdfForms.new.cat(*filled_out_documents.push(output_file.path))
      ClientPdfDocument.create_or_update(
        output_file: output_file,
        document_type: DocumentTypes::Form1040,
        client: client,
        filename: pdf_bundle_filename,
        tax_return: tax_return
      )
    else
      pdf_documents = bundle_class.new(self).pdf_documents
      output_file = Tempfile.new(["tax_document", ".pdf"], "tmp/")
      filled_out_documents = pdf_documents.map { |document| document.pdf.new(self, **document.kwargs).output_file }
      PdfForms.new.cat(*filled_out_documents.push(output_file.path))
      output_file
    end
  end

  def manifest_class
    if STATE_INTAKE_CLASS_NAMES.include?(data_source_type)
      return SubmissionBuilder::StateManifest
    end

    SubmissionBuilder::FederalManifest
  end

  def bundle_class
    if data_source&.class == StateFileNyIntake
      return SubmissionBuilder::Ty2023::States::Ny::IndividualReturn
    elsif data_source&.class == StateFileAzIntake
      return SubmissionBuilder::Ty2023::States::Az::IndividualReturn
    end

    case tax_year
    when 2020
      SubmissionBuilder::Ty2020::Return1040
    when 2021
      SubmissionBuilder::Ty2021::Return1040
    when 2022
      SubmissionBuilder::Ty2021::Return1040
    when 2023
      SubmissionBuilder::Ty2021::Return1040
    end
  end

  ##
  # Re-enqueue the submission to handle a temporary error.
  #
  # If the submission was enqueued more than 1 day ago, give up and transition to :failed.
  # Always grabs the latest transition to queued so in cases where a user resubmits, we begin the 1 day expiration at that point.
  #
  # This method assumes the submission has already been transitioned to :queued. If the transition
  # was never enqueued, transition to :failed to cover the programming error.
  def retry_send_submission
    now = DateTime.now.utc
    queued_at = efile_submission_transitions.where(to_state: "queued").pluck(:created_at).max
    if queued_at.nil?
      transition_to!(:failed, error_code: "TRANSMISSION-SERVICE", raw_response: "Unable to retry_send_submission because submission was never queued.")
      return
    end

    age = now.to_time - queued_at.to_time
    if age > 1.days
      transition_to!(:failed, error_code: "TRANSMISSION-SERVICE", raw_response: "Deadline exceeded when retrying send submission. Waited for about 1 day.")
      return
    end

    max_backoff = 60.minutes
    backoff =
      if age > max_backoff
        max_backoff
      else
        age ** 1.25
      end
    retry_wait = backoff + SecureRandom.rand(30)
    GyrEfiler::SendSubmissionJob.set(wait_until: now + retry_wait).perform_later(self)
  end

  def create_qualifying_dependents
    # TODO(state-file)
    return unless intake

    qualifying_dependents.delete_all

    intake.dependents.each do |dependent|
      EfileSubmissionDependent.create_qualifying_dependent(self, dependent)
    end
  end

  def generate_irs_submission_id!(i = 0)
    return if self.irs_submission_id.present?

    raise "Max irs_submission_id attempts exceeded. Too many submissions today?" if i > 5

    efin = EnvironmentCredentials.irs(:efin)
    irs_submission_id = "#{efin}#{Date.current.strftime('%C%y%j')}#{SecureRandom.base36(7)}"
    if self.class.find_by(irs_submission_id: irs_submission_id)
      i += 1
      generate_irs_submission_id!(i)
    else
      self.update!(irs_submission_id: irs_submission_id)
    end
  end
end
