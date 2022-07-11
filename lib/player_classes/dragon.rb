class Dragon < DefaultPlayer
  @player_actions = []
  class << self
    attr_accessor :player_actions
  end
  
  has_action :fire_breath do |targets|
    fire = Splash.new(name: "fire_breath", dmg_mod: 5, action_msg: "#{self.name} breaths fire over the arena...", stat_val: self.strength)
    fire.use(self, targets)
  end

  def self.all_player_actions
    player_actions + super
  end
end