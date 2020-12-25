# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    plr1, plr2 = data.split("\n\n")
    @plr1 = plr1.split("\n")[1..].map(&:to_i)
    @plr2 = plr2.split("\n")[1..].map(&:to_i)
  end

  def one
    # keep going until one goes empty
    round = 0
    winner = nil
    while @plr1.empty? == @plr2.empty?
      round += 1
      puts "-- Round #{round} --"
      puts "Player 1's deck: #{@plr1.join(", ")}"
      puts "Player 2's deck: #{@plr2.join(", ")}"
      a, b = @plr1.shift, @plr2.shift
      puts "Player 1 plays: #{a}\nPlayer 2 plays: #{b}"
      if a > b
        puts "Player 1 wins the round!"
        @plr1 << a
        @plr1 << b
        winner = @plr1
      else
        puts "Player 2 wins the round!"
        @plr2 << b
        @plr2 << a
        winner = @plr2
      end
      puts

      # win_size = winner.size
    end

    puts "== Post-game results =="
    puts "Player 1's deck: #{@plr1.join(", ")}"
    puts "Player 2's deck: #{@plr2.join(", ")}"

    winner.reverse.zip(1..(winner.size)).map {|p| p.inject(:*)}.sum
  end

  def serialise_cards(cards)
    cards.zip((1..(cards.size)).map{|x|(10**(x-1))}).map {|x| x.inject(&:*)}.sum
  end

  def play_game(n, plr1, plr2)
    with_print = false

    plr1_seen = {}
    plr2_seen = {}

    puts "=== Game #{n} ===" if with_print
    puts if with_print

    # keep going until one goes empty
    round = 0
    winner = nil
    while plr1.empty? == plr2.empty?
      round += 1


      puts "-- Round #{round} (Game #{n}) --" if with_print

      # Prevent infinitely recursive games
      plr1_ser = serialise_cards(plr1)
      plr2_ser = serialise_cards(plr2)
      if plr1_seen[plr1_ser] && plr2_seen[plr2_ser]
        puts 'bye' if with_print
        return 1
      end

      plr1_seen[plr1_ser] = true
      plr2_seen[plr2_ser] = true
      # Done preventing infinitely recursive games

      puts "Player 1's deck: #{plr1.join(", ")}" if with_print
      puts "Player 2's deck: #{plr2.join(", ")}" if with_print
      a, b = plr1.shift, plr2.shift
      puts "Player 1 plays: #{a}\nPlayer 2 plays: #{b}" if with_print
      one_ok = plr1.size >= a
      two_ok = plr2.size >= b

      if one_ok && two_ok
        puts 'Playing a sub-game to determine the winner...' if with_print
        puts if with_print
        winner_id = play_game(n+1, plr1[0..(a-1)], plr2[0..(b-1)])
        puts "...anyway, back to game #{n}." if with_print
        puts "Player #{n} wins round #{round} of game #{n}!" if with_print
        if winner_id == 1
          winner = plr1
          plr1 << a
          plr1 << b
        else
          winner = plr2
          plr2 << b
          plr2 << a
        end
      elsif a > b
        puts "Player 1 wins round #{round} of game #{n}!" if with_print
        plr1 << a
        plr1 << b
        winner = plr1
      else
        puts "Player 2 wins round #{round} of game #{n}!" if with_print
        plr2 << b
        plr2 << a
        winner = plr2
      end
      puts if with_print

      # win_size = winner.size
    end

    winner_id = (winner == plr1) ? 1 : 2
    puts "The winner of game #{n} is player #{winner_id}!" if with_print

    if n == 1
      [plr1, plr2]
    else
      winner_id
    end
  end

  def two
    plr1, plr2 = play_game(1, @plr1, @plr2)
    winner = plr1.size == 0 ? plr2 : plr1
    puts "== Post-game results =="
    puts "Player 1's deck: #{plr1.join(", ")}"
    puts "Player 2's deck: #{plr2.join(", ")}"
    winner.reverse.zip(1..(winner.size)).map {|p| p.inject(:*)}.sum
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.read

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
