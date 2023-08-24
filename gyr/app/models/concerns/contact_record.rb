module ContactRecord
  extend ActiveSupport::Concern

  def contact_record_type
    self.class.name.underscore.to_sym
  end

  def formatted_time
    datetime.strftime("%l:%M %p #{datetime.zone}").strip
  end
end
