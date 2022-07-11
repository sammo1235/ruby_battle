class Human < DefaultPlayer
  @player_actions = []
  class << self
    attr_accessor :player_actions
  end

  def initialize(*attrs)
    super(*attrs)

    @name ||= "HumanDefault"
    @dodge = 3
    @intelligence = 8
    @current_health = 125
    @max_health = 125
    @strength = 4
    @block = 5
    @player ||= false

  end

  has_action :trick do |targets|
    trick = SingleTarget.new(user: self, targets: [self], action_msg: "doesn't fall for it and attacks", dmg_mod: 3)
    trick.user = trick.select_target(targets)

    puts "#{@name} tries to talk their way out of an encounter with #{trick.user.name}..."

    if (self.intelligence + Random.new.rand(1..10)) <= (trick.user.intelligence + Random.new.rand(1..10))
      trick.stat_val = trick.user.strength
      trick.use
    else
      trick = Buff.new(user: self, action_msg: "#{@name} somehow succeeded. They escape to a corner to heal")
      trick.use("health", 15)
    end
  end

  has_action :potion do |targets|
    splash = Splash.new(name: "throw_potion", dmg_mod: 6, action_msg: "#{@name} throws a potion...", stat_val: self.intelligence)
    splash.use(self, targets)
  end

  def self.all_player_actions
    player_actions + super
  end
end