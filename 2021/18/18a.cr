class Node
  def initialize(@a : Node | Int32, @b : Node | Int32)
  end

  property :a
  property :b

  def to_s(io)
    io << '[' << a << ',' << b << ']'
  end
end

def split(c)
  a = c.a
  case a
  when Node
    return true if split(a)
  when Int32
    if a > 9
      c.a = Node.new((a / 2).floor.to_i, (a / 2).ceil.to_i)
      return true
    end
  end

  a = c.b
  case a
  when Node
    return true if split(a)
  when Int32
    if a > 9
      c.b = Node.new((a / 2).floor.to_i, (a / 2).ceil.to_i)
      return true
    end
  end
end

def explode(c, d)
  t = 0

  x = c.a
  case x
  when Node
    if d == 3
      c.a = 0
      a, b = x.a, x.b
      return { {a, b}, t } if a.is_a?(Int32) && b.is_a?(Int32)
    else
      b, n = explode(x, d + 1)
      t += n
      return {b, t} if b
    end
  when Int32
    t += 1
  end

  x = c.b
  case x
  when Node
    if d == 3
      c.b = 0
      a, b = x.a, x.b
      return { {a, b}, t } if a.is_a?(Int32) && b.is_a?(Int32)
    else
      b, n = explode(x, d + 1)
      t += n
      return {b, t} if b
    end
  when Int32
    t += 1
  end

  {nil, t}
end

def add(c, pos, val, t)
  x = c.a
  case x
  when Node
    t = add(x, pos, val, t)
  when Int32
    t += 1
    c.a = x + val if t == pos
  end

  x = c.b
  case x
  when Node
    t = add(x, pos, val, t)
  when Int32
    t += 1
    c.b = x + val if t == pos
  end

  t
end

def mag(c : Node | Int32)
  case c
  when Node
    mag(c.a) * 3 + mag(c.b) * 2
  else
    c
  end
end

def parse(s)
  if s[0] == '['
    r1, n1 = parse(s[1..])
    r2, n2 = parse(s[n1 + 2..])
    {Node.new(r1, r2), n1 + n2 + 3}
  else
    {s[0].to_i, 1}
  end
end

vs = [] of Node | Int32
File.each_line(ARGV[0]) do |l|
  vs << parse(l)[0]
end
c = vs[0]
vs[1..].each do |v|
  c = Node.new(c, v)
  loop do
    b, n = explode(c, 0)
    if b
      add(c, n, b[0], 0)
      add(c, n + 2, b[1], 0)
      next
    end
    next if split(c)
    break
  end
end

puts c
puts mag(c)
