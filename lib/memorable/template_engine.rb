require 'singleton'

module Memorable

  # This is an abstract class, do not use it directly. Inherit from this class
  # and implement custom load!/parse/render medthods.
  class TemplateEngine
    include Singleton

    # Class Methods
    # --------------------------
    # Override this method in subclass
    def self.load!
    end

    def self.assemble(*args)
      instance.assemble(*args)
    end

    # Instance Methods
    # --------------------------
    #
    attr_reader :load_path, :templates

    def initialize
      @load_path = []
      @templates = {}
    end

    def assemble(options)
      parse(options[:controller], options[:action], options[:template_key]).map do |locale, template|
        content = render(template, options)
        [locale, content]
      end
    end

    # Override this method in subclass
    def parse(controller, action, sub_key)
    end
  end
end

require 'memorable/template_engines/default'
