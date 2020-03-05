module PublicPagesHelper
  def enable_online_intake?
    return true unless Rails.env.production?

    ENV['ENABLE_ONLINE_INTAKE'].present? && session[:source] != 'propel'
  end
end
