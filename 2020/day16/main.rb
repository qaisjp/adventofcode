# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'set'

class Rule < T::Struct
  extend T::Sig

  prop :id, String

  prop :min1, Integer
  prop :max1, Integer

  # or this
  prop :min2, Integer
  prop :max2, Integer

  def valid?(x)
    (min1 <= x && x <= max1) || (min2 <= x && x <= max2)
  end

  # returns scan success
  sig {params(line: String).returns(T.nilable(Rule))}
  def self.scan(line)
    id, rhs = line.strip.split(":")

    # "your ticket", "nearby tickets"
    if rhs.nil?
      return nil
    end

    range1, range2 = T.must(rhs).split(" or ")
    min1, max1 = T.must(range1).split("-").map(&:to_i)
    min2, max2 = T.must(range2).split("-").map(&:to_i)

    Rule.new(id: T.must(id), min1: T.must(min1), max1: T.must(max1), min2: T.must(min2), max2: T.must(max2))
  end
end

RawTicket = T.type_alias {T::Array[Integer]}

# AoC
class AoC
  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @rules = T.let([], T::Array[Rule])

    @yours = T.let([], RawTicket)
    @nearby = T.let([], T::Array[RawTicket])

    stage = T.let(0, Integer)

    data.each do |line|
      line = line.strip
      next if line == ""

      if stage == 0
        rule = Rule.scan(line)
        if rule.nil?
          stage = 1
        else
          @rules << rule
        end
      elsif stage == 1
        if line != "your ticket:"
          @yours = line.split(",").map(&:to_i)
          stage = 2
        end
      elsif stage == 2
        if line != "nearby tickets:"
          @nearby << line.split(",").map(&:to_i)
        end
      end
    end
  end

  def one
    invalid = []
    # puts "#{@rules}"
    # puts "ours: #{@yours}"
    # puts "nearby: #{@nearby}"

    @nearby.each do |nums|
      nums.each do |num|
        valid = @rules.any? {|rule| rule.valid? num}
        if !valid
          invalid << num
        end
      end
    end

    puts "Invalid: #{invalid}"
    invalid.sum
  end


  def two
    # puts "#{@rules}"
    # puts "ours: #{@yours}"
    # puts "nearby: #{@nearby}"

    unknown_rules = @rules.dup
    rules_to_know = unknown_rules.dup
    if rules_to_know.size > 4
      rules_to_know.filter! {|r| r.id.start_with? "departure"}
    end
    puts "Rules to know: #{rules_to_know}"

    total_cols = @nearby.fetch(0).size
    column_to_rules = T.let({}, T::Hash[Integer, T::Array[Rule]])
    total_cols.times.each do |col_id|
      column_to_rules[col_id] = @rules.dup
    end

    # known_cols = T.let({}, T::Hash[Integer, Rule])

    # Filter out invalids
    @nearby.filter! do |nums|
      nums.all? do |num|
        @rules.any? {|rule| rule.valid? num}
      end
    end

    known_columns_to_rule = T.let({}, T::Hash[Integer, Rule])

    iters = 0
    while !rules_to_know.empty?
      iters += 1
      puts "\n\n\n============= ITERATION #{iters} =============="

      # For each column...
      column_to_rules.each do |col_id, potential_col_rules|
        if potential_col_rules.first.nil?
          puts "\n### ALREADY thought about #{col_id}, it's #{known_columns_to_rule.fetch(col_id).id}"
          next
        end
        puts "\n### Thinking about column #{col_id}"

        # Check each ticket to see if there are any rules that disagree
        @nearby.each do |columns|
          # puts "- Ticket: #{columns}"
          # And don't consider that rule in future iterations, if the rule disagrees
          potential_col_rules.filter! do |rule|
            rule.valid? columns[col_id]
          end

          # If the above filter filtered down to 1, make sure to do some sanitisation:
          # - remove from all columns' potential col rules
          # - assign in known_columns_to_rule
          # - remove from rules_to_know
          #
          # We can also stop processing tickets for this column, since we figured it out! (break)
          if potential_col_rules[1].nil?
            found_rule = potential_col_rules.fetch(0)
            puts "√√√√ Column #{col_id} is #{found_rule.id}"
            column_to_rules.each {|_, potentials| potentials.delete(found_rule)}
            known_columns_to_rule[col_id] = found_rule
            rules_to_know.delete(found_rule)
            break
          end
        end
      end

      ######
      ###### OLD BROKEN CODE
      ###### This loops through each ticket and considers each column. The new code loops through each column and considers each ticket.
      ######
      # @nearby.each do |columns|
      #   puts "\n\n==== TICKET: #{columns}" if should_print
      #   column_to_rules.reject! do |col_id, potential_col_rules|
      #     col_num = columns.fetch(col_id)
      #     found = T.let(false, T::Boolean)
      #     puts "\n= Considering #{col_id} (val: #{col_num})" if should_print

      #     potential_col_rules.reject! do |rule|
      #       if rule.valid?(col_num)
      #         puts "#{col_num} passes #{rule.id}" if should_print
      #         next false
      #       end

      #       puts "#{col_num} does not pass #{rule.id}." if should_print

      #       if potential_col_rules.size == 1
      #         the_rule = potential_col_rules.fetch(0)
      #         puts "#{col_id} is #{the_rule.id}!!!!!!!!!!!!!!"
      #         found = true
      #         rules_to_know.delete(the_rule)

      #         column_to_rules.each do |this_col_id, potentials|
      #           next if this_col_id == col_id
      #           potentials.delete(the_rule)
      #         end
      #       end

      #       next true
      #     end

      #     found
      #   end
      # end
    end

    puts "column_to_rules: #{column_to_rules}"
    puts "known_columns_to_rule: #{known_columns_to_rule}"

    nums = []
    known_columns_to_rule.each do |col_id, rule|
      if rule.id.start_with? "departure"
        nums << @yours.fetch(col_id)
      end
    end

    nums.inject(:*)
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
