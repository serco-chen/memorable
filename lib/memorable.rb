require 'active_support'

require 'memorable/version'
require 'memorable/error'
require 'memorable/registration'
require 'memorable/template_engine'
require 'memorable/model'
require 'memorable/controller'

module Memorable
  @config = ActiveSupport::OrderedOptions.new

  class << self
    attr_reader :config

    def setup(&block)
      yield config if block_given?
      config.template_engine      ||= DefaultYAMLEngine
      config.error_on_development ||= :raise
      config.error_on_production  ||= :log
      config.log_model = Object.const_get(config.log_model)

      ActionController::Base.send :include, Memorable::Controller
    end
  end
end
