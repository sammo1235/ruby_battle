module PlayerAttributes
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

module PlayerActions
  class ActionNotImplementedError < StandardError; end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def has_actions(*actions)
      actions.each do |action|
        self.send(:define_method, action) do |*args|
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

  def random_action(other_player)
    self.send(self.class.all_player_actions.sample, other_player)
  end
end

class DefaultPlayer
  @default_player_actions = []
  class << self
    attr_accessor :default_player_actions
  end  
  include PlayerAttributes
  include PlayerActions
  
  has_attributes :name, :health, :strength, :damage
  has_actions :attack, :run

  class PlayerIsDead < StandardError; end
  def attack(other_player)
    other_player.health -= self.damage
    puts "#{self.name} attacks #{other_player.name} and does #{self.damage} damage"
    puts "#{other_player.name} now has #{other_player.health} health"
    raise PlayerIsDead, "#{other_player.name} has died" if other_player.health <= 0
  end

  def run(other_player)
    self.health += 15
    puts "#{self.name} runs from #{other_player.name} and does 0 damage"
    puts "#{self.name} now has #{self.health} health"
  end
end
  
class Human < DefaultPlayer
  @player_actions = []
  class << self
    attr_accessor :player_actions
  end

  has_action :talk_their_way_out_of_it do |other|
    self.health += 10
    puts "#{self.name} has talked their way out of this encounter, and gained 10 health."
  end

  has_action :throws_potion do |other|
    other.health -= 50
    puts "#{self.name} has thrown a potion, dealing 50 damage."
    raise PlayerIsDead, "#{other.name} has died" if other.health <= 0
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
  
  has_action :stomp do |other|
    other.health -= 20
    puts "#{self.name} has stomped on #{other.name} and dealt 20 damage."
    raise PlayerIsDead, "#{other.name} has died" if other.health <= 0
  end

  def self.all_player_actions
    player_actions + super
  end
end

class Battle
  class TooManyPlayersError < StandardError; end
  attr_reader :players
  def initialize(*players)
    # currently only accepts two players
    raise TooManyPlayersError if players.count > 2

    @players = players
    puts "Battle has been initialized"
    puts "=" * 8
  end

  def shuffle_players
    players.shuffle
  end

  def player_update
    players.each do |player|
      puts "#{player.name} has #{player.health} health"
    end
    puts "=" * 8

  end

  def begin
    (1..100).each do |round|
      puts "Round #{round}"
      (current, other) = shuffle_players

      current.random_action(other)
      player_update
    end
  end
end

john = Human.new(name: "John", health: 100, strength: 20, damage: 25)
dragon = Dragon.new(name: "Boromir", health: 200, strength: 100, damage: 55)

Battle.new(john, dragon).begin