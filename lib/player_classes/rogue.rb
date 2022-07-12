class Rogue < DefaultArchetype
  @archetype_actions = []
  class << self
    attr_accessor :archetype_actions
  end

  def initialize()
    super()

    @name ||= "Defaultarchetype"
    @dodge = 3
    @intelligence = 1
    @current_health = -30
    @max_health = @current_health
    @strength = 0
    @block = 0

    @sneak_attack = SingleTarget.new(name: "sneak_attack", dmg_mod: 7, action_msg: "sneak attack!", stat_val: @intelligence, count: 2)

    @action_count = {}
    @action_count[:sneak_attack] = @sneak_attack
  end

  has_action :sneak_attack do |user, targets|
    @sneak_attack.user = user
    @sneak_attack.targets = targets
    @sneak_attack.use
  end

  def self.all_archetype_actions
    archetype_actions + super
  end

  def action_count
    @action_count
  end
end
