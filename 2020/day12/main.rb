# frozen_string_literal: true

require 'sorbet-runtime'

# AoC
class AoC
  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @data = T.let(data, T::Array[String])
  end

  # degrees only bois
  def cos(x); Math.cos(Math::PI*x/180) end
  def sin(x); Math.sin(Math::PI*x/180) end


  def one
    ship = 0 + 0i
    angle = 0 # east is 0
    @data.each do |line|
      direction = line[0]
      distance = line[1..].to_i

      puts "\n#{direction}#{distance} (from #{ship})"

      if direction == "N"
        ship += distance * 1i
      elsif direction == "E"
        ship += distance
      elsif direction == "S"
        ship -= distance*1i
      elsif direction == "W"
        ship -= distance
      elsif direction == "L"
        angle += distance
      elsif direction == "R"
        angle -= distance
      elsif direction == "F"
        ship += (distance * (cos(angle) + (1i*sin(angle))))
      end
      puts "Moved to #{ship} bearing #{angle}"
    end

    puts ""
    return ship.real.abs.round + ship.imag.abs.round
  end

  def two
    ship = 0 + 0i
    waypoint = 10 + 1i
    # angle east is 0
    @data.each do |line|
      direction = line[0]
      distance = line[1..].to_i

      puts "\n#{direction}#{distance} (from waypoint #{waypoint}, ship #{ship})"

      if direction == "N"
        waypoint += distance*1i
      elsif direction == "E"
        waypoint += distance
      elsif direction == "S"
        waypoint -= distance*1i
      elsif direction == "W"
        waypoint -= distance
      elsif direction == "L"
        angle = distance
        waypoint *= cos(angle) + (1i*sin(angle))
      elsif direction == "R"
        angle = -distance
        waypoint *= cos(angle) + (1i*sin(angle))
      elsif direction == "F"
        ship += distance * waypoint
      end
      puts "Waypoint: #{waypoint}. Ship: #{ship}. Bearing #{angle}"
    end

    puts ""
    return ship.real.abs.round + ship.imag.abs.round
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
