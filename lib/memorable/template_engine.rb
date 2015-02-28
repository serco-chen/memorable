module Memorable

  # This is an abstract class, do not use it directly. Inherit from this class
  # and implement custom render medthods.
  class TemplateEngine

    def self.run(*args)
      self.new.render(*args)
    end

    # Override this method in subclass
    def render(*args)
    end

  end
end

require 'memorable/template_engines/default'
