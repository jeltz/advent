def r(s)
  s[0] - 'w'
end

def f(prog, pos, reg, code, seen)
  while pos < prog.size - 1
    pos += 1
    c = prog[pos]
    case c[0]
    when :inp
      key = {pos, reg[3]} # we only care about z
      return if seen.includes?(key)
      seen << key

      (1..9).reverse_each do |d|
        nreg = reg.dup
        nreg[c[1]] = d.to_i64
        r = f(prog, pos, nreg, code + d.to_s, seen)
        return r if r
      end
      return
    when :add
      reg[c[1]] = reg[c[1]] + c[2]
    when :addr
      reg[c[1]] = reg[c[1]] + reg[c[2]]
    when :mul
      reg[c[1]] = reg[c[1]] * c[2]
    when :mulr
      reg[c[1]] = reg[c[1]] * reg[c[2]]
    when :div
      reg[c[1]] = (reg[c[1]] / c[2]).to_i64
    when :divr
      reg[c[1]] = (reg[c[1]] / reg[c[2]]).to_i64
    when :mod
      reg[c[1]] = reg[c[1]] % c[2]
    when :modr
      reg[c[1]] = reg[c[1]] % reg[c[2]]
    when :eql
      reg[c[1]] = (reg[c[1]] == c[2] ? 1 : 0).to_i64
    when :eqlr
      reg[c[1]] = (reg[c[1]] == reg[c[2]] ? 1 : 0).to_i64
    else
      raise "Unknown command #{c}"
    end
  end
  code if reg[3] == 0
end

prog = File.read(ARGV[0]).lines

prog = prog.map do |l|
  case l
  when /^inp ([a-z])$/
    {:inp, r($1), 0}
  when /^add ([a-z]) (-?\d+)$/
    {:add, r($1), $2.to_i}
  when /^add ([a-z]) ([a-z])$/
    {:addr, r($1), r($2)}
  when /^mul ([a-z]) (-?\d+)$/
    {:mul, r($1), $2.to_i}
  when /^mul ([a-z]) ([a-z])$/
    {:mulr, r($1), r($2)}
  when /^div ([a-z]) (-?\d+)$/
    {:div, r($1), $2.to_i}
  when /^div ([a-z]) ([a-z])$/
    {:divr, r($1), r($2)}
  when /^mod ([a-z]) (-?\d+)$/
    {:mod, r($1), $2.to_i}
  when /^mod ([a-z]) ([a-z])$/
    {:modr, r($1), r($2)}
  when /^eql ([a-z]) (-?\d+)$/
    {:eql, r($1), $2.to_i}
  when /^eql ([a-z]) ([a-z])$/
    {:eqlr, r($1), r($2)}
  else
    raise "Unknown command #{l}"
  end
end

puts f(prog, -1, [0i64, 0i64, 0i64, 0i64], "", Set(Tuple(Int32, Int64)).new)
