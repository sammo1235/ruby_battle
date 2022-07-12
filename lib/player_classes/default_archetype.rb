module ArchetypeAttributes
  require "colorize"

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  class ArchetypeMustHaveNameError < StandardError; end

  def initialize()
    
  end

  module ClassMethods
    def has_attributes(*attrs)
      attr_accessor(*attrs)
    end
  end
end

module ArchetypeActions
  class ActionNotImplementedError < StandardError; end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def has_actions(*actions)
      actions.each do |action|
        send(:define_method, action) do
          raise ActionNotImplementedError, "this action has not been given to this player yet"
        end
        default_archetype_actions << action
      end
    end

    def all_archetype_actions
      DefaultArchetype.default_archetype_actions
    end

    def has_action(action, &block)
      send(:define_method, action, block)
      archetype_actions << action
    end
  end
end

class DefaultArchetype
  @default_archetype_actions = []
  class << self
    attr_accessor :default_archetype_actions
  end
  include ArchetypeAttributes
  include ArchetypeActions

  has_attributes :name, :current_health, :max_health, :strength, :intelligence, :damage, :block, :dodge
  has_actions

  def action_counts
    @action_count
  end
end
