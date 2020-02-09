module ZendeskPartnerHelper
  ONLINE_INTAKE_THC_UWBA_STATES = %w(co nm ne ks ca ak fl nv sd tx wa wy).freeze
  ONLINE_INTAKE_GWISR_STATES = %w(ga al).freeze
  EITC_INSTANCE_STATES = (ONLINE_INTAKE_THC_UWBA_STATES + ONLINE_INTAKE_GWISR_STATES).freeze

  def state
    @intake.state
  end

  def instance
    @instance ||= instance_for_state
  end

  def instance_for_state
    if (EITC_INSTANCE_STATES.include? state) || state.nil?
      EitcZendeskInstance
    else
      UwtsaZendeskInstance
    end
  end

  def instance_eitc?
    instance == EitcZendeskInstance
  end

  def group_id_for_state
    if ONLINE_INTAKE_THC_UWBA_STATES.include? state
      EitcZendeskInstance::ONLINE_INTAKE_THC_UWBA
    elsif ONLINE_INTAKE_GWISR_STATES.include? state
      EitcZendeskInstance::ONLINE_INTAKE_GWISR
    else
      # we do not yet have group ids for UWTSA Zendesk instance
      nil
    end
  end
end