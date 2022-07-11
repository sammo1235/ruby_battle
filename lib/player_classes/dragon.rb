class Dragon < DefaultPlayer
  @player_actions = []
  class << self
    attr_accessor :player_actions
  end

  def initialize(*attrs)
    super(*attrs)

    @name ||= "DragonDefault"
    @dodge = 1
    @intelligence = 7
    @current_health = 150
    @max_health = 150
    @strength = 5
    @block = 5
    @player ||= false

    @fire = Splash.new(name: "fire_breath", dmg_mod: 5, action_msg: "#{@name} breaths fire over the arena...", stat_val: @strength, count: 1)

    @action_count[:fire_breath] = @fire
  end

  has_action :fire_breath do |targets|
    @fire.use(self, targets)
  end

  def self.all_player_actions
    player_actions + super
  end
end
