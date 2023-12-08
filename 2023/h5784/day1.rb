# typed: true

require 'json'
require 'scanf'
require 'set'
require 'sorbet-runtime'
require 'benchmark'
require 'pry'

class H5784
    Mapping = T.let({
        0 => [' '],
        1 => [],
        2 => "ABC".chars,
        3 => "DEF".chars,
        4 => "GHI".chars,
        5 => "JKL".chars,
        6 => "MNO".chars,
        7 => "PQRS".chars,
        8 => "TUV".chars,
        9 => "WXYZ".chars
    }, T::Hash[Integer, T::Array[String]])

    def main
        File.read("./data/noahs-customers.jsonl").split("\n").each do |line|
            JSON.parse(line, symbolize_names: true) => {name:, phone:}
            o_phone = phone
            phone = phone.tr("-", "")
            surname = name.upcase.split(" ")[1]

            puts(o_phone) if surname.chars.each_with_index.all? do |c, index|
                digit = phone.chars.fetch(index).to_i
                Mapping.fetch(digit).include? c
            end
        end
    end
end

H5784.new.main
