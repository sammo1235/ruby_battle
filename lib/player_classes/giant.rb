class Giant < DefaultPlayer
  @player_actions = []
  class << self
    attr_accessor :player_actions
  end

  def initialize(*attrs)
    super(*attrs)

    @name ||= "GiantDefault"
    @dodge = 0
    @intelligence = 3
    @current_health = 150
    @max_health = 150
    @strength = 7
    @block = 10
    @player ||= false

    @stomp = SingleTarget.new(name: "stomp", user: self, dmg_mod: 5, action_msg: "stomps on", stat_val: strength, count: 2)
    @war_cry = Buff.new(name: "war_cry", user: self)

    @action_count[:stomp] = @stomp
    @action_count[:war_cry] = @war_cry
  end

  has_action :stomp do |targets|
    @stomp.targets = targets
    @stomp.use
  end

  has_action :war_cry do |targets|
    puts "#{name} lets out a rallying war cry"

    random = Random.new.rand(1..10)
    if random <= 3
      @war_cry.action_msg = "Everyone laughts at #{name}"
      @war_cry.use("health", (-10 * targets.size))
    else
      @war_cry.action_msg = "Everyone cowers before #{name}"
      @war_cry.use("block", 20)
    end
  end

  def self.all_player_actions
    player_actions + super
  end
end
