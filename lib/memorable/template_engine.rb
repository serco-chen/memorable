module Memorable

  # This is an abstract class, do not use it directly. Inherit from this class
  # and implement custom render medthods.
  class TemplateEngine

    def self.run(params)
      self.new.render(params)
    end

    # Override this method in subclass
    def render(params)
    end

  end
end

require 'memorable/template_engines/default'
