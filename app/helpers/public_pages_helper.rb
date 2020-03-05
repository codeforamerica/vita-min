module PublicPagesHelper
  def enable_online_intake?
    ENV['ENABLE_ONLINE_INTAKE'].present? && controller.source != 'propel'
  end
end
