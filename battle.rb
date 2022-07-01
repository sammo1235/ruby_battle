module PlayerAttributes
  require 'colorize'

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  class PlayerMustHaveNameError < StandardError; end
  def initialize(*attrs)
    attrs = attrs.select {|a| a.is_a? Hash }.first
    raise PlayerMustHaveNameError unless attrs.keys.include? :name
    attrs.each do |attr, value|
      instance_variable_set("@#{attr}", value)
    end
  end

  module ClassMethods
    def has_attributes(*attrs)
      attr_accessor *attrs
    end
  end
end

module ActionAttributes
  require 'colorize'

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def initialize(*attrs)
    attrs = attrs.select {|a| a.is_a? Hash }.first
    attrs.each do |attr, value|
      instance_variable_set("@#{attr}", value)
    end
  end

  module ClassMethods
    def has_attributes(*attrs)
      attr_accessor *attrs
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
        self.send(:define_method, action) do
          raise ActionNotImplementedError, "this action has not been given to this player yet"
        end
        self.default_player_actions << action
      end
    end

    def all_player_actions
      DefaultPlayer.default_player_actions
    end

    def has_action(action, &block)
      self.send(:define_method, action , block)
      self.player_actions << action
    end
  end

  # I do not want this here
  def show_target_health(target)
    puts "#{target.name} now has #{current_health}/#{max_health} HP"
  end

  def random_action(targets)
    self.send(self.class.all_player_actions.sample, targets)
  end

  def player_turn(targets)
    actions = self.class.all_player_actions.map { |s| s.to_s }

    puts "Pick an action: #{actions}"
    action = gets
    player_turn(targets) unless actions.include?(action.strip.downcase)

    i = actions.index(action.strip.downcase)

    self.send(self.class.all_player_actions[i], targets) if actions.include?(action.strip.downcase)
  end

  def calculate_damage(attacker, damage_mod, target, can_dodge = true)
    damage = 0

    if can_dodge == true
      # See if the target dodges the attack
      random = Random.new.rand(1..10)
      return "but #{target.name} dodges and takes 0 damage" if random <= target.dodge
    end

    # Calculate damage based on attacker strength and target block
    damage = damage_mod * attacker.strength

    # Minus block from attack and then reduce block by attack amount (can't go negative)
    block_difference = target.block.clone - damage.clone
    damage_result = "for #{damage.clone} but #{target.name} blocks #{target.block.clone} " if target.block > 0

    damage -= target.block
    

    # reduce block by damage done
    target.block = block_difference 
    target.block = 1 if target.block <= 0

    damage = 0 if damage < 0
    target.current_health -= damage
    
    damage_result += "and #{target.name} takes #{damage} damage"
  end
end

class Action
  include ActionAttributes
  has_attributes :user, :targets, :dmg_mod, :stat_val, :action_msg

  def calculate_damage(attacker, damage_mod, target, can_dodge = true)
    damage = 0

    if can_dodge == true
      # See if the target dodges the attack
      random = Random.new.rand(1..10)
      return "but #{target.name} dodges and takes 0 damage" if random <= target.dodge
    end

    # Calculate damage based on attacker strength and target block
    damage = damage_mod * self.stat_val

    # Minus block from attack and then reduce block by attack amount (can't go negative)
    block_difference = target.block.clone - damage.clone
    damage_result = "for #{damage.clone} but #{target.name} blocks #{target.block.clone} " if target.block > 0

    damage -= target.block
    

    # reduce block by damage done
    target.block = block_difference 
    target.block = 1 if target.block <= 0

    damage = 0 if damage < 0
    target.current_health -= damage
    
    damage_result += "and #{target.name} takes #{damage} damage"
  end

  def select_target(targets)
    target = targets.first

    if self.user&.player == true
      target_names = []
      targets.each do |t|
        target_names.push(t.name.downcase)
      end
      puts "Pick a target from #{target_names}"
      selection = gets
      
      use(self.user, targets) unless target_names.include?(selection.strip.downcase)

      targets.each do |t|
        if selection.strip.downcase == t.name.strip.downcase
          target = t
        end
      end 
    else
      target = targets.sample
    end

    target
  end
end

class SingleTarget < Action
  def use
    targets = self.targets
    target = select_target(targets)
    
    damage_result = calculate_damage(self.user, self.dmg_mod, target)
    puts "#{self.user.name} #{self.action_msg} #{target.name} #{damage_result}"
  end
end

class Splash < Action
  def use(attacker, targets)
    puts action_msg
    targets.each do |target|
      damage_result = calculate_damage(attacker, self.dmg_mod, target)
      puts "#{damage_result}"
    end
  end
end

class Buff < Action
  def use(stat, buff_mod)
    case stat
    when "block"
      self.user.block += buff_mod
    when "health"
      self.user.current_health += buff_mod
    when "dodge"
      self.user.dodge += buff_mod
    end

    if buff_mod > 0
      puts "#{self.action_msg}, they increase their #{stat} increases by #{buff_mod}"
    else
      puts "#{self.action_msg}, their #{stat} decreases by #{buff_mod}"
    end
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
    target = targets[Random.new.rand(0..(targets.size-1))]
  end

  def attack(targets)
    attack = SingleTarget.new(user: self, targets: targets, dmg_mod: 4, action_msg: "attacks", stat_val: self.strength)
    attack.use
  end

  def prepare(var)
    prepare = Buff.new(user: self, action_msg: "#{self.name} hunkers down to prepare for coming attacks")
    prepare.use("block", 5)
  end
end
  
class Human < DefaultPlayer
  @player_actions = []
  class << self
    attr_accessor :player_actions
  end

  has_action :trick do |targets|
    trick = SingleTarget.new(user: self, targets: [self], action_msg: "doesn't fall for it and attacks", dmg_mod: 3)
    trick.user = trick.select_target(targets)
  

    puts "#{self.name} tries to talk their way out of an encounter with #{trick.user.name}..."

    if (self.intelligence + Random.new.rand(1..10)) <= (trick.user.intelligence + Random.new.rand(1..10))
      trick.stat_val = trick.user.strength
      trick.use
    else
      trick = Buff.new(user: self, action_msg: "#{self.name} somehow succeeded. They escape to a corner to heal")
      trick.use("health", 15)
    end
  end

  has_action :throws_potion do |targets|
    splash = Splash.new(name: "throw_potion", dmg_mod: 4, action_msg: "#{self.name} throws a potion...", stat_val: self.intelligence)
    splash.use(self, targets)
  end

  def self.all_player_actions
    player_actions + super
  end
end

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

class Battle
  class TooManyPlayersError < StandardError; end
  class LastPlayerLeft < StandardError; end
  class InvalidPlayerCount < StandardError; end

  attr_reader :players
  def initialize(*players)

    @players = players
    puts "Battle has been initialized"
    puts "=" * 8
  end

  def shuffle_players
    players.shuffle
  end

  def check_if_dead(players)
    players.each do |player|
      if player.current_health <= 0
        puts "#{player.name} has been eliminated".red
        # # `say #{player.name} has been eliminated` 
        players.delete(player)
        puts "players left: #{players}"
      end
    end
  end

  def player_update(players)
    check_if_dead(players)
    puts "Totals:".light_blue
    players.each do |player|
      puts "#{player.name} (#{player.class}): #{player.current_health}/#{player.max_health} HP and #{player.block} block".light_blue
    end
    raise LastPlayerLeft, "#{players[0].name} is the last player remaining! VICTORY!!!" if players.size <= 1
    puts "=" * 8
  end


  def begin
    users = setPlayers
    npcs = setNPCs

    # `say FIGHT`
    (1..100).each do |round|  
      # `say Round #{round}`
      puts "Round #{round}".green
      players = shuffle_players

      players.each_with_index do |current, i|
        targets = players.clone 
        targets.delete_at(i)

        if users.include?(current)
          puts "Its #{current.name}'s action..."
          # `say Its #{current.name}s turn`
          current.player_turn(targets)
        else
          current.random_action(targets)
        end
        puts "..."
        player_update(players)
      end
      
      puts "press any key to continue to next round..."
      gets
    end
  end

  def setNPCs
    puts "Select number of NPCs to fight against"
    count = Integer(gets) rescue nil
    raise InvalidPlayerCount, "please put in a valid number" unless count

    names = ["Steve", "Sam", "Jess", "Scott", "Anneka", "Chelsea"]

    (1..count).each do |i|
      # TO LEARN: There has to be a better way to do this
      random = Random.new.rand(1..3)
      case random
      when 1
        players.push(Human.new(name: names.sample, current_health: 80, max_health: 80, strength: 6, intelligence:8, block: 5, dodge: 5))
      when 2
        players.push(Dragon.new(name: names.sample, current_health: 125, max_health: 125, strength: 8, block: 5, intelligence: 5, dodge: 2))
      when 3
        players.push(Giant.new(name: names.sample, current_health: 150, max_health: 150, strength: 10, block: 5, intelligence: 3, dodge: 1))
      end
    end
  end

  def setPlayers
    puts "Select number of players"
    player_count = Integer(gets) rescue nil
    raise InvalidPlayerCount, "please put in a valid number" unless player_count
    current_players = []

    if player_count == 100 #lets dev skip character creation
      bob = Human.new(name: "bob", current_health: 80, max_health: 80, strength: 6, block: 5, dodge: 5, intelligence: 8, player: true)
      puts "you have chosen bob"
      current_players.push(bob)
      players.push(bob)
    else
      (1..player_count).each do |i|
        player = setPlayer
        current_players.push(player)
        players.push(player)
      end
    end
    current_players
  end

  def setPlayer
    puts "Pick a race by typing one of the following options - Human/Dragon/Giant"
    race = gets
    race = race.strip.downcase
    setPlayer unless ["human", "giant", "dragon"].include?(race.strip.downcase)

    puts "Enter a username:"
    name = gets.capitalize
    case race
    when "human"
      player = Human.new(name: name.strip, current_health: 80, max_health: 80, strength: 5, intelligence: 8, block: 5, dodge: 5, player: true)
    when "dragon"
      player = Dragon.new(name: name.strip, current_health: 125, max_health: 125, strength: 8, block: 5, intelligence: 6, dodge: 2, player: true)
    when "giant"
      player = Giant.new(name: name.strip, current_health: 150, max_health: 150, strength: 10, block: 5, intelligence: 3, dodge: 1, player: true)
    else
      puts "how did we get here"
    end

    puts "player created, press any key to continue...".green
    gets

    player
  end

end

Battle.new().begin