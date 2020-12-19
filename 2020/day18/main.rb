# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @data = T.let(data, T::Array[String])

    @prec_map1 = {"*" => 1, "+" => 1}
    @prec_map2 = {"*" => 1, "+" => 2}
  end

  sig {params(n: String).returns(T.nilable(Integer))}
  def as_num(n)
    begin
      Integer(n)
    rescue ArgumentError
      nil
    end
  end

  # Convert input to RPN via the https://en.wikipedia.org/wiki/Shunting-yard_algorithm
  sig {params(tokens: T::Array[String], prec_map: T::Hash[String, Integer]).returns(String)}
  def shunting_yard(tokens, prec_map)
    output = []
    ops = []

    tokens.each do |token|
      token_num = as_num(token)
      prec = prec_map[token]

      if !token_num.nil?
        output << token
      elsif !prec.nil?
        while !ops.empty? && (ops.last != "(") && (prec_map.fetch(ops.last) >= prec)
          output << ops.pop
        end
        ops << token
      elsif token == "("
        ops << token
      elsif token == ")"
        while ops.last != "("
          output << ops.pop
        end
        if ops.last == "("
          ops.pop
        end
      end
    end

    while !ops.empty?
      output << ops.pop
    end
    output.join(" ")
  end

  sig {params(rpn_str: String).returns(Integer)}
  def eval(rpn_str)
    ts = rpn_str.split
    stack = []
    ts.each do |t|
      tn = as_num(t)
      if tn.nil?
        if t == "*"
          stack << stack.pop * stack.pop
        elsif t == "+"
          stack << stack.pop + stack.pop
        else
          raise "que"
        end
      else
        stack << tn
      end
    end
    stack.first
  end

  def tokenise(input)
    input.gsub(/(\(|\))/, ' \1 ').split
  end

  def try1(input, expected)
    tokens = tokenise(input)
    puts "\n\ninput #{input} tokenised to #{tokens.inspect}"
    rpn = shunting_yard(tokens, @prec_map1)
    puts "rpn #{rpn}"
    evaled = eval(rpn)
    puts "eq #{evaled}"
    if evaled != expected
      raise "got #{evaled} expected #{expected}"
    end

  end

  def one
    try1("1 + 2 * 3 + 4 * 5 + 6", 71)
    try1("1 + (2 * 3) + (4 * (5 + 6))", 51)
    try1("2 * 3 + (4 * 5)", 26)
    try1("5 + (8 * 3 + 9 + 3 * 4 * 3)", 437)
    try1("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 12240)
    try1("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 13632)

    @data.sum do |line|
      eval(shunting_yard(tokenise(line), @prec_map1))
    end
  end

  def two
    @data.sum do |line|
      eval(shunting_yard(tokenise(line), @prec_map2))
    end
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines(chomp: true).to_a

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
