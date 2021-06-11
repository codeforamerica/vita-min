module Routes
  class GyrDomain
    def matches?(request)
      !Routes::CtcDomain.new.matches?(request)
    end
  end
end
