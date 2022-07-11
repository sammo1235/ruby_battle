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