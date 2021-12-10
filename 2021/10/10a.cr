total = 0
scores = {')' => 3, ']' => 57, '}' => 1197, '>' => 25137}
File.each_line(ARGV[0]) do |l|
  e = [] of Char
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
        total += scores[c]
        break
      end
    end
  end
end
puts total
