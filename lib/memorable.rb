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
      ActionController::Base.send :include, Memorable::Controller

      config.template_engine ||= DefaultYAMLEngine
    end
  end
end
