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

      config.journals_model.send  :include, Memorable::Model
      ActionController::Base.send :include, Memorable::Controller

      config.default_templates_directory ||= File.dirname(__FILE__)
      config.template_engine             ||= DefaultYAMLEngine

      config.template_engine.load!
    end
  end
end
