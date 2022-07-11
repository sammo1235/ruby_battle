module PlayerAttributes
  require "colorize"

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  class PlayerMustHaveNameError < StandardError; end

  def initialize(*attrs)
    attrs = attrs.find { |a| a.is_a? Hash }
    attrs.each do |attr, value|
      instance_variable_set("@#{attr}", value)
    end

    @attack = SingleTarget.new(name: "attack", user: self, dmg_mod: 4, action_msg: "attacks")
    @prepare = Buff.new(name: "prepare", user: self, action_msg: "#{@name} hunkers down to prepare for coming attacks")
  
    @action_count = {
      attack: @attack,
      prepare: @prepare
    }
  end

  module ClassMethods
    def has_attributes(*attrs)
      attr_accessor(*attrs)
    end
  end
end

module PlayerActions
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
        default_player_actions << action
      end
    end

    def all_player_actions
      DefaultPlayer.default_player_actions
    end

    def has_action(action, &block)
      send(:define_method, action, block)
      player_actions << action
    end
  end

  # I do not want this here
  def show_target_health(target)
    puts "#{target.name} now has #{current_health}/#{max_health} HP"
  end

  def random_action(targets)
    send(self.class.all_player_actions.sample, targets)
  end

  def player_turn(targets)
    actions = self.class.all_player_actions.map { |s| s.to_s }

    msg =  "Pick an action: "
    self.action_counts.values.each_with_index do |a, i|
      msg += "[#{a.name} (#{a.count}/#{a.max_count})]"
    end

    puts msg
    action = gets
    player_turn(targets) unless actions.include?(action.strip.downcase)

    i = actions.index(action.strip.downcase)

    send(self.class.all_player_actions[i], targets) if actions.include?(action.strip.downcase)
  end
end

class DefaultPlayer
  @default_player_actions = []
  class << self
    attr_accessor :default_player_actions
  end
  include PlayerAttributes
  include PlayerActions

  has_attributes :name, :current_health, :max_health, :strength, :intelligence, :damage, :block, :dodge, :player
  has_actions :attack, :prepare

  def pick_target(targets)
    targets[Random.new.rand(0..(targets.size - 1))]
  end

  def attack(targets) 
    @attack.stat_val = @strength
    @attack.targets = targets
    @attack.use
  end

  def prepare(var)
    @prepare.use("block", 5)
  end

  def action_counts
    @action_count
  end
end
