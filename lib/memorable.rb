require 'active_support'

require 'memorable/version'
require 'memorable/error'
require 'memorable/configuration'
require 'memorable/template_engine'
require 'memorable/model'
require 'memorable/controller'

module Memorable

  class << self
    def setup(&block)
      Configuration.class_eval(&block) if block_given?
      Configuration.journal_model.send :include, Memorable::Model
      ActionController::Base.send      :include, Memorable::Controller
    end
  end

  TemplateEngine.load!
end
