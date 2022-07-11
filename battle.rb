require './lib/player_classes/default_player.rb'
require './lib/actions/action.rb'
require './lib/actions/single_target.rb'
require './lib/actions/splash.rb'
require './lib/actions/buff.rb'
require './lib/player_classes/human.rb'
require './lib/player_classes/dragon.rb'
require './lib/player_classes/giant.rb'

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
    @players.shuffle
  end

  def player_update(players)
    puts "Totals:".light_blue
    @players.each do |player|
      if player.current_health <= 0
        # # `say #{player.name} has been eliminated` 
        @players.delete(player)
        puts "#{player.name} has been eliminated".red
      else
        puts "#{player.name} (#{player.class}): #{player.current_health}/#{player.max_health} HP and #{player.block} block".light_blue
      end
    end
    raise LastPlayerLeft, "#{players[0].name} is the last player remaining! VICTORY!!!" if players.size <= 1
    puts "=" * 8

    @players
  end


  def begin
    users = setPlayers
    npcs = setNPCs

    puts "The fighters are:".red
    @players.each do |player|
      puts "#{player.name} (#{player.class}): #{player.current_health}/#{player.max_health} HP".red
    end
    # `say FIGHT`
    (1..100).each do |round|  
      # `say Round #{round}`
      puts "Round #{round}".green
      @players = shuffle_players

      @players.each_with_index do |current, i|
        targets = @players.clone 
        targets.delete_at(i)

        if users.include?(current)
          puts "Its #{current.name}'s action..."
          # `say Its #{current.name}s turn`
          current.player_turn(targets)
        else
          current.random_action(targets)
        end
        puts "..."
        @players = player_update(@players)
      end
      
      puts "press any key to continue to next round..."
      gets
    end
  end

  def setNPCs
    puts "Select number of NPCs to fight against"
    count = Integer(gets) rescue nil
    raise InvalidPlayerCount, "please put in a valid number" unless count

    names = ["Steve", "Sam", "Jess", "Scott", "Anneka", "Chelsea", "Jonny", "Corin", "Paris"]

    (1..count).each do |i|
      # TO LEARN: There has to be a better way to do this
      random = Random.new.rand(1..3)
      case random
      when 1
        @players.push(Human.new(name: names.delete_at(rand(names.length))))
      when 2
        @players.push(Dragon.new(name: names.delete_at(rand(names.length))))
      when 3
        @players.push(Giant.new(name: names.delete_at(rand(names.length))))
      end
    end
  end

  def setPlayers
    puts "Select number of players"
    player_count = Integer(gets) rescue nil
    raise InvalidPlayerCount, "please put in a valid number" unless player_count
    current_players = []

    if player_count == 100 #lets dev skip character creation
      bob = Human.new(name: "Bob", player: true)
      puts "you have chosen bob"
      current_players.push(bob)
      @players.push(bob)
    else
      (1..player_count).each do |i|
        player = setPlayer
        current_players.push(player)
        @players.push(player)
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
      player = Human.new(name: name.strip, player: true)
    when "dragon"
      player = Dragon.new(name: name.strip, player: true)
    when "giant"
      player = Giant.new(name: name.strip, player: true)
    else
      puts "how did we get here"
    end

    puts "player created, press any key to continue...".green
    gets

    player
  end

end

Battle.new().begin