module ContactRecord
  extend ActiveSupport::Concern

  def contact_record_type
    self.class.name.underscore.to_sym
  end
end