module Memorable

  # This is the default engine, which uses I18n to find the template and
  # to interpolate variables.
  class DefaultYAMLEngine < TemplateEngine

    def render(locals)
      controller, action, sub_key = locals[:controller], locals[:action], locals[:template_key] || 'base'
      @key ||= "memorable.#{controller}.#{action}.#{sub_key}"
      begin
        I18n.t! @key, locals
      rescue I18n::MissingTranslationData => e
        raise e if @key.start_with?("memorable.defaults")
        @key = "memorable.defaults.#{action}.#{sub_key}"
        retry
      end
    end
  end
end
