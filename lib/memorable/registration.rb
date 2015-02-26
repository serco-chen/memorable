module Memorable
  class Registration
    @register_actions = {}

    class << self
      attr_reader :register_actions

      def register(action_names, controller_name, options, condition_proc)
        register_actions[controller_name] ||= {}
        register_actions[controller_name][:actions] ||= []
        register_actions[controller_name][:actions].concat([action_names].flatten)
        register_actions[controller_name][:options] ||= {}
        register_actions[controller_name][:options].merge! options
        register_actions[controller_name][:condition_proc] ||= condition_proc
      end

      def registered?(key, name)
        register_actions[key] && register_actions[key][:actions].include?(name)
      end

      def condition_matched?(controller)
        condition = condition_proc(controller.controller_name)
        return true unless condition
        return controller.instance_eval(&condition)
      end

      def controller_options(key)
        register_actions[key][:options] rescue nil
      end

      def condition_proc(key)
        register_actions[key][:condition_proc] rescue nil
      end

      # Controller Options Helpers
      def  resource_name(key)
        register_actions[key][:options][:resource_name] rescue nil
      end
    end
  end
end
