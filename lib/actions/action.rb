module ActionAttributes
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def initialize(*attrs)
    attrs = attrs.find { |a| a.is_a? Hash }
    attrs.each do |attr, value|
      instance_variable_set("@#{attr}", value)
    end
  end

  module ClassMethods
    def has_attributes(*attrs)
      attr_accessor(*attrs)
    end
  end
end

class Action
  include ActionAttributes
  has_attributes :user, :targets, :dmg_mod, :stat_val, :action_msg

  def calculate_damage(attacker, damage_mod, target, can_dodge = true)
    if can_dodge == true
      # See if the target dodges the attack
      random = Random.new.rand(1..10)
      return "but #{target.name} dodges and takes 0 damage" if random <= target.dodge
    end

    # Calculate damage based on attacker strength and target block
    damage = damage_mod * stat_val

    # Minus block from attack and then reduce block by attack amount (can't go negative)
    block_difference = target.block.clone - damage.clone
    damage_result = "for #{damage.clone} but #{target.name} blocks #{target.block.clone} " if target.block > 0

    damage -= target.block

    # reduce block by damage done
    target.block = block_difference
    target.block = 1 if target.block <= 0

    damage = 0 if damage < 0
    target.current_health -= damage

    damage_result + "and #{target.name} takes #{damage} damage"
  end

  def select_target(targets)
    target = targets.first

    if user&.player == true
      target_names = []
      targets.each do |t|
        target_names.push(t.name.downcase)
      end
      puts "Pick a target from #{target_names}"
      selection = gets

      use(user, targets) unless target_names.include?(selection.strip.downcase)

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
