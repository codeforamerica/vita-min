require "erb"

class MessageRenderer
  def self.render(template, locals: {})
    new(template, locals).render
  end

  def initialize(template, locals)
    @template = template
    @locals = locals
  end

  def render
    erb = ERB.new(@template, trim_mode: "-")
    erb.result_with_hash(@locals)
  end
end
