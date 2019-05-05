class Ai
  def initialize
    @x = [[1,2], [3,4]]
  end
  def update
    @x[0][0] = 5
  end
  getter :x
end
  
a = Ai.new
p a.x
b = a.x.clone
p b
a.update
p a.x
p b