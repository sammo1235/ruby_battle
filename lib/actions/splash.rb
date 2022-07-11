class Splash < Action
  def use(attacker, targets)
    puts action_msg
    targets.each do |target|
      damage_result = calculate_damage(attacker, self.dmg_mod, target)
      puts "#{damage_result}"
    end
  end
end