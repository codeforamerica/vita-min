module OmniAuth
  module Strategies
    autoload :IdMe, Rails.root.join('lib', 'strategies', 'idme.rb')
  end
end