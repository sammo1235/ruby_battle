class Splash < Action
  def use(attacker, targets)
    super()

    puts @action_msg
    targets.each do |target|
      damage_result = calculate_damage(attacker, @dmg_mod, target)
      puts damage_result.to_s
    end
  end
end
