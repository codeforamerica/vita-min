class RevealComponent < ViewComponent::Base
  def initialize(title:, tracking_ref: nil)
    @title = title
    @body = yield
    @tracking_ref = tracking_ref || make_tracking_ref
  end

  def make_tracking_ref
    @title.downcase.gsub(/\W/, '_')
  end
end
