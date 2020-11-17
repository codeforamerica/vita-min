class EitcZendeskInstance
  # Digital Intake Status value tags
  INTAKE_STATUS_UNSTARTED = ""
  INTAKE_STATUS_IN_PROGRESS = "1._new_online_submission"
  INTAKE_STATUS_GATHERING_DOCUMENTS = "online_intake_gathering_documents"
  INTAKE_STATUS_READY_FOR_REVIEW = "online_intake_ready_for_review"
  INTAKE_STATUS_IN_REVIEW = "online_intake_in_review"
  INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW = "online_intake_ready_for_intake_interview"
  INTAKE_STATUS_WAITING_FOR_INFO = "online_intake_waiting_for_info"
  INTAKE_STATUS_COMPLETE = "3._ready_for_prep"
  INTAKE_STATUS_NOT_FILING = "online_intake_not_filing"

  INTAKE_STATUS_LABELS = {
    INTAKE_STATUS_UNSTARTED => "Unstarted",
    INTAKE_STATUS_IN_PROGRESS => "In Progress",
    INTAKE_STATUS_GATHERING_DOCUMENTS => "Gathering Documents",
    INTAKE_STATUS_READY_FOR_REVIEW => "Ready For Review",
    INTAKE_STATUS_IN_REVIEW => "In Review",
    INTAKE_STATUS_READY_FOR_INTAKE_INTERVIEW => "Ready For Intake Interview",
    INTAKE_STATUS_WAITING_FOR_INFO => "Waiting For Info",
    INTAKE_STATUS_COMPLETE => "Complete",
    INTAKE_STATUS_NOT_FILING => "Not Filing",
  }

  # Zendesk Ticket Return Statuses
  RETURN_STATUS_UNSTARTED = ""
  RETURN_STATUS_IN_PROGRESS = "1._in_progress"
  RETURN_STATUS_READY_FOR_QUALITY_REVIEW = "2._ready_for_quality_review"
  RETURN_STATUS_READY_FOR_SIGNATURE_ESIGN = "3a._ready_for_signature__e-sign"
  RETURN_STATUS_READY_FOR_SIGNATURE_PICKUP = "3b._ready_for_signature__pick-up"
  RETURN_STATUS_READY_FOR_EFILE = "4._ready_for_e-file"
  RETURN_STATUS_COMPLETED_RETURNS = "5._completed_returns"
  RETURN_STATUS_DO_NOT_FILE = "6._do_not_file"
  RETURN_STATUS_FOREIGN_STUDENT = "7._foreign_student"

  RETURN_STATUS_LABELS = {
    RETURN_STATUS_UNSTARTED => "Unstarted",
    RETURN_STATUS_IN_PROGRESS => "In Progress",
    RETURN_STATUS_READY_FOR_QUALITY_REVIEW => "Ready For Quality Review",
    RETURN_STATUS_READY_FOR_SIGNATURE_ESIGN => "Ready For Signature E-Sign",
    RETURN_STATUS_READY_FOR_SIGNATURE_PICKUP	=> "Ready For Signature Pick-Up",
    RETURN_STATUS_READY_FOR_EFILE => "Ready For E-File",
    RETURN_STATUS_COMPLETED_RETURNS => "Completed Returns",
    RETURN_STATUS_DO_NOT_FILE => "Do Not File",
    RETURN_STATUS_FOREIGN_STUDENT => "Foreign Student",
  }

  EIP_STATUS_STARTED = "started_eip_only_form"
  EIP_STATUS_ID_UPLOAD = "reached_id_upload_page"
  EIP_STATUS_SUBMITTED = "submitted_eip_only_form"
  EIP_STATUS_READY_FOR_PHONE_CALL = "ready_for_phone_call"
  EIP_STATUS_PREP_IN_PROGRESS = "eip_prep_in_progress"
  EIP_STATUS_SIGNATURE = "waiting_on_signature"
  EIP_STATUS_COMPLETED = "completed_eip_return"

  EIP_STATUS_LABELS = {
    EIP_STATUS_STARTED => "Started EIP only form",
    EIP_STATUS_ID_UPLOAD => "Reached ID upload page",
    EIP_STATUS_SUBMITTED => "Submitted EIP only form",
    EIP_STATUS_READY_FOR_PHONE_CALL => "Ready for phone call",
    EIP_STATUS_PREP_IN_PROGRESS => "EIP prep in progress",
    EIP_STATUS_SIGNATURE => "Waiting on signature",
    EIP_STATUS_COMPLETED => "Completed EIP return",
  }
end