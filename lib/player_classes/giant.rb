class Giant < DefaultPlayer
  @player_actions = []
  class << self
    attr_accessor :player_actions
  end
  
  has_action :stomp do |targets|
    stomp = SingleTarget.new(user: self, targets: targets, dmg_mod: 5, action_msg: "stomps on", stat_val: self.strength)
    stomp.use
  end

  has_action :war_cry do |targets|
    puts "#{self.name} lets out a rallying war cry"

    random = Random.new.rand(1..10)
    war_cry = Buff.new(user: self)
    if random <= 3 
      war_cry.action_msg = "Everyone laughts at #{self.name}"
      war_cry.use("health", (-10 * targets.size))
    else
      war_cry.action_msg = "Everyone cowers before #{self.name}"
      war_cry.use("block", 20)
    end
  end

  def self.all_player_actions
    player_actions + super
  end
end