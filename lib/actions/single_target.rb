class SingleTarget < Action
  def use
    targets = self.targets
    target = select_target(targets)

    damage_result = calculate_damage(user, dmg_mod, target)
    puts "#{user.name} #{action_msg} #{target.name} #{damage_result}"
  end
end
