module Buildable
  extend ActiveSupport::Concern

  class_methods do
    def build(*args)
      new(*args).build
    end
  end
end