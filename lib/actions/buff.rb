class Buff < Action
  def use(stat, buff_mod)
    super()
    case stat
    when "block"
      user.block += buff_mod
    when "health"
      user.current_health += buff_mod
    when "dodge"
      user.dodge += buff_mod
    end

    if buff_mod > 0
      puts "#{action_msg}, they increase their #{stat} increases by #{buff_mod}"
    else
      puts "#{action_msg}, their #{stat} decreases by #{buff_mod}"
    end
  end
end
