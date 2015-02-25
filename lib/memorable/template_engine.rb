require 'singleton'
require 'yaml'

module Memorable
  class TemplateEngine
    include Singleton

    attr_reader :load_path, :templates

    def initialize
      @load_path = []
      @templates = {}
    end

    def store_templates
      load_path.each do |filename|
        locale = File.basename(filename, ".yml")
        data = load_yml filename
        templates[locale.to_sym] = data
      end
    end

    # Loads a YAML template file. The data must have locales as
    # toplevel keys.
    def load_yml(filename)
      begin
        YAML.load_file(filename)
      rescue TypeError, ScriptError, StandardError => e
        raise InvalidYAMLData.new(filename, e.inspect)
      end
    end

    def assemble(options)
      action_templates(options.controller, options.action, options.template_key).map do |locale, template|
        content = render_template(template, options)
        [locale, content]
      end
    end

    protected

    def render_template(template, locals)
      if locals
        I18n.interpolate(template, locals)
      else
        template
      end
    end

    def action_templates(controller, action, sub_key)
      sub_key ||= 'base'
      raw_templates = catch(:template_found) do
        parse_entry(controller, action, sub_key)
        parse_entry(controller, 'other', sub_key)
        parse_entry('defaults', action, sub_key)
        parse_entry('defaults', 'other', sub_key)
        nil
      end
      raise TemplateNotFound, "Template: #{controller} #{action} #{sub_key} not found" unless raw_templates
      raw_templates
    end

    def parse_entry(controller, action, sub_key)
      raw_templates = templates.map do |locale, template_data|
        template = template_data[controller][action][sub_key] rescue nil
        template ? [locale, template] : nil
      end.compact
      throw :template_found, raw_templates unless raw_templates.blank?
    end

    # Class Methods
    # ----------------------
    #
    def self.load!
      pattern = self.pattern_from I18n.available_locales

      add("templates/#{pattern}.yml")
      add("app/views/memorable/#{pattern}.yml", Rails.root)

      instance.store_templates
    end

    def self.render(*args)
      instance.render(*args)
    end

    protected

    def self.add(pattern, base_dir=File.dirname(__FILE__))
      files = Dir[File.join(base_dir, pattern)]
      instance.load_path.concat(files)
    end

    def self.pattern_from(args)
      array = Array(args || [])
      array.blank? ? '*' : "{#{array.join ','}}"
    end
  end
end
