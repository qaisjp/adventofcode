# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

class Op < T::Enum
  enums do
    ADD = new("+")
    MUL = new("*")
  end
end

class TokenKind < T::Enum
  enums do
    OpAdd = new("OP_ADD")
    OpMul = new("OP_MUL")
    LParen = new("L_PAREN")
    RParen = new("R_PAREN")
    Num = new("NUM")
  end
end

class Token < T::Struct
  extend T::Sig

  const :kind, TokenKind
  const :_num, T.nilable(Integer), default: nil
  const :_char, T.nilable(String), default: nil

  sig {returns(T::Boolean)}
  def is_num?
    kind == TokenKind::Num
  end

  sig {returns(Integer)}
  def num
    raise "num access on token #{kind}" unless is_num?
    T.must(@_num)
  end

  sig {returns(String)}
  def inspect
    if kind == TokenKind::Num
      "#{kind.serialize}(#{num})"
    else
      kind.serialize
    end
  end

  sig {params(char: String).returns(Token)}
  def self.op_from_char(char)
    [OpAdd, OpMul].find {|t| t._char == char}
  end

  sig {returns(Op)}
  def op
    if self == OpAdd
      Op::ADD
    elsif self == OpMul
      Op::MUL
    else
      raise
    end
  end

  def to_s
    inspect
  end
end

# Singleton tokens
OpAdd = Token.new(kind: TokenKind::OpAdd, _char: "+")
OpMul = Token.new(kind: TokenKind::OpMul, _char: "*")
LParen = Token.new(kind: TokenKind::LParen, _char: "(")
RParen = Token.new(kind: TokenKind::RParen, _char: ")")

class Tokenizer
  extend T::Sig

  sig {params(input: String).returns(T::Array[Token])}
  def self.run(input)
    input.split(" ").map do |str|
      tokens = T::Array[Token].new
      rtokens = T::Array[Token].new
      if str[0] == "("
        tokens = Array.new(str.count("("), LParen)
        str = str.delete("(")
      elsif str[-1] == ")"
        rtokens = Array.new(str.count(")"), RParen)
        str = str.delete(")")
      end

      begin
        tokens << num(Integer(str))
      rescue ArgumentError
        tokens << Token.op_from_char(str)
      end
      tokens += rtokens
      tokens
    end.flatten
  end

  sig {params(num: Integer).returns(Token)}
  def self.num(num)
    Token.new(kind: TokenKind::Num, _num: num)
  end

  sig {params(input: String, expected: String).void}
  def self.try(input, expected)
    actual = run(input).map(&:to_s).join(" ")
    if actual != expected
      raise "[TEST] Token #{input} incorrect. Got \n#{actual}\n, expected \n#{expected}"
    end
  end

  def self.test
    try("2 + 3", "NUM(2) OP_ADD NUM(3)")
    try("1 + 2 * 3 + 4 * 5 + 6", "NUM(1) OP_ADD NUM(2) OP_MUL NUM(3) OP_ADD NUM(4) OP_MUL NUM(5) OP_ADD NUM(6)")
    try("1 + (2 * 3) + (4 * (5 + 6))", "NUM(1) OP_ADD L_PAREN NUM(2) OP_MUL NUM(3) R_PAREN OP_ADD L_PAREN NUM(4) OP_MUL L_PAREN NUM(5) OP_ADD NUM(6) R_PAREN R_PAREN")
    puts "[TEST} Tokenizer passes"
  end
end

Node = T.type_alias {T.any(Expr, Integer)}
class Expr < T::Struct
  extend T::Sig

  const :left, Node
  const :op, Op
  const :right, Node

  def inspect
    "(#{left.inspect} #{op.serialize} #{right.inspect})"
  end

  sig {returns(Integer)}
  def evaluate
    l = T.let(0, Integer)
    r = T.let(0, Integer)

    case left
    when Integer
      l = left
    when Expr
      l = left.evaluate
    else
      T.absurd(left)
    end

    case right
    when Integer
      r = right
    when Expr
      r = right.evaluate
    else
      T.absurd(right)
    end

    case op
    when Op::MUL
      l * r
    when Op::ADD
      l + r
    else
      T.absurd(op)
    end
  end
end

class Parser
  extend T::Sig

  sig {params(tokens: T::Array[Token]).returns(Expr)}
  def self.expr(tokens)
    last = tokens.last
    second_last = T.let(tokens[-2], T.nilable(Token))

    if last&.is_num? && ((second_last == OpAdd) || (second_last == OpMul))
      second_last = T.must(second_last)
      Expr.new(
        left: node(T.must(tokens[0..tokens.size-3])),
        op: second_last.op,
        right: last.num,
      )
    elsif last == RParen
      # Seek tokens backwards until we've popped all parentheses off the stack
      left = tokens.size - 1 # the last item is already rparen...
      found = 1 # so we set this to 1
      while found > 0
        # in the initial loop, the last is rparen. skip over this
        left -= 1

        if tokens[left] == RParen
          found += 1
        elsif tokens[left] == LParen
          found -= 1
        end
      end

      ltokens = tokens[0..left-2]
      op = tokens.fetch(left-1)
      rtokens = tokens[left+1..tokens.size-2]

      # puts "#{ltokens} #{op} #{rtokens}"
      Expr.new(
        left: node(T.must(ltokens)),
        op: op.op,
        right: node(T.must(rtokens)),
      )
    else
      raise "Not sure what to do with #{tokens}"
    end
  end

  sig {params(tokens: T::Array[Token]).returns(Node)}
  def self.node(tokens)
    if tokens.size == 1
      tokens.fetch(0).num
    else
      expr(tokens)
    end
  end

  sig {params(string: String, expected: String).void}
  def self.try(string, expected)
    actual = Parser.expr(Tokenizer.run(string)).inspect
    if actual != expected
      raise "Test for #{string} failed. Got #{actual}, expected #{expected}"
    end
  end

  def self.test
    puts "[TEST} Parser passes"
    try("2 + 3", "(2 + 3)")
    try("1 + 2 * 3 + 4 * 5 + 6", "(((((1 + 2) * 3) + 4) * 5) + 6)")
    try("2 * 3 + (4 * 5)", "((2 * 3) + (4 * 5))")

    #   Expr.new(left: 1, op: Op::ADD, right: Expr.new(
    #     left: 2, op: Op::MUL, right: Expr.new(
    #       left: 3, op: Op::ADD, right: Expr.new(
    #         left: 4, op: Op::MUL, right: Expr.new(
    #           left: 5, op: Op::ADD, right: 6),
    #         ),
    #       ),
    #     ),
    #   ),
    # )
  end

end
