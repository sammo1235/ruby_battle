class SingleTarget < Action
  def use
    targets = self.targets
    target = select_target(targets)
    
    damage_result = calculate_damage(self.user, self.dmg_mod, target)
    puts "#{self.user.name} #{self.action_msg} #{target.name} #{damage_result}"
  end
end