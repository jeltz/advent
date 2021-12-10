totals = [] of Int64
scores = {')' => 1, ']' => 2, '}' => 3, '>' => 4}
File.each_line(ARGV[0]) do |l|
  e = [] of Char
  valid = true
  l.each_char do |c|
    case c
    when '('
      e.push(')')
    when '['
      e.push(']')
    when '{'
      e.push('}')
    when '<'
      e.push('>')
    else
      if e[-1] == c
        e.pop
      else
        valid = false
        break
      end
    end
  end
  if valid
    total = 0.to_i64
    e.reverse_each do |c|
      total *= 5
      total += scores[c]
    end
    totals << total
  end
end
puts totals.sort[(totals.size / 2).to_i]
