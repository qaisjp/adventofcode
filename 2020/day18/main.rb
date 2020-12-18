# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# enable tco
RubyVM::InstructionSequence.compile_option = {
  tailcall_optimization: true,
  trace_instruction: true,
}

require_relative './parser.rb'

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @data = T.let(data, T::Array[String])
  end

  sig {params(string: String, expected: Integer).void}
  def try(string, expected)
    tokens = Tokenizer.run(string)
    expr = Parser.expr(tokens)
    actual = expr.evaluate
    if actual != expected
      raise "Test for #{string} failed. Got #{actual}, expected #{expected}.\nTokens: #{tokens}\nExpr: #{expr.inspect}"
    end
    puts "[TEST] #{string} is #{expected}"
  end

  def test
    Tokenizer.test
    Parser.test
    try("1 + 2 * 3 + 4 * 5 + 6", 71)
    try("1 + (2 * 3) + (4 * (5 + 6))", 51)
    try("2 * 3 + (4 * 5)", 26)
    try("5 + (8 * 3 + 9 + 3 * 4 * 3)", 437)
    try("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 12240)
    try("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 13632)

  end

  def one
    @data.map do |line|
      tokens = Tokenizer.run(line)
    end
    []
  end

  def two

  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines(chomp: true).to_a

  runner.test

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main


# validate_expr("2 + 9", Expr.new(left: 2, op: Op::ADD, right: 9))
