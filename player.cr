class Player
  def initialize(color : Int32)
    @color = color
  end

  def put_stone(board : Board, turn : Int32) : Array(Int32)
    return [0,0]
  end

  getter :color
end
