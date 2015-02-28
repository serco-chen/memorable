module Memorable

  # This is the default engine, which uses I18n to find the template and
  # to interpolate variables.
  class DefaultYAMLEngine < TemplateEngine

    def render(params)
      controller, action, sub_key = params[:controller], params[:action], params[:template_key] || 'base'
      @key ||= "#{controller}.#{action}.#{sub_key}"
      begin
        I18n.t @key, params
      rescue MissingTranslationData => e
        raise e if @key.start_with("defaults")
        @key = "defaults.#{action}.#{sub_key}"
        retry
      end
    end
  end
end
