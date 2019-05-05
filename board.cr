require_relative "./constant"

class Board
  #新しい盤
  def initialize
    #盤面を表す二重配列の作成
    @board = [
      [WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL], 
      [WALL,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,WALL], 
      [WALL,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,WALL], 
      [WALL,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,WALL], 
      [WALL,EMPTY,EMPTY,EMPTY,WHITE,BLACK,EMPTY,EMPTY,EMPTY,WALL], 
      [WALL,EMPTY,EMPTY,EMPTY,BLACK,WHITE,EMPTY,EMPTY,EMPTY,WALL], 
      [WALL,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,WALL], 
      [WALL,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,WALL], 
      [WALL,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,EMPTY,WALL], 
      [WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL,WALL]
    ]
  end

  attr_reader :board

  #現在の盤の状態を表示
  def show_board
    print("\n\n  #{COL_NUM.keys.join(" ")}") #列
    @board.each_with_index do |row, i| #番兵を除く
      print(ROW_NUM[(i).to_s])
      row.each do |col|
        case col
        when EMPTY
          print "\e[32m"
          print(" □")
          print "\e[0m"
        when BLACK
          print(" ○")
        when WHITE
          print(" ●")
        end
      end
      print("\n")
    end
    print("\n")
    stone_count = count
    print("\n 黒:#{stone_count[0]}, 白:#{stone_count[1]}\n\n")
  end

  #石をひっくり返す
  def reverse(row, col, color) #石をおいた位置
    @board[row][col] = color
    turn_direction = turnable_direction(row, col, color) #返せる方向を取得
    if turn_direction & UPPER_LEFT != 0
      i = 1
      while @board[row-i][col-i] == -color #相手の色が続くまで
        @board[row-i][col-i] = color
        i += 1
      end
    end
    if turn_direction & UPPER != 0
      i = 1
      while @board[row-i][col] == -color
        @board[row-i][col] = color
        i += 1
      end
    end
    if turn_direction & UPPER_RIGHT != 0
      i = 1
      while @board[row-i][col+i] == -color
        @board[row-i][col+i] = color
        i += 1
      end
    end
    if turn_direction & RIGHT != 0
      i = 1
      while @board[row][col+i] == -color
        @board[row][col+i] = color
        i += 1
      end
    end
    if turn_direction & LOWER_RIGHT != 0
      i = 1
      while @board[row+i][col+i] == -color
        @board[row+i][col+i] = color
        i += 1
      end
    end
    if turn_direction & LOWER != 0
      i = 1
      while @board[row+i][col] == -color
        @board[row+i][col] = color
        i += 1
      end
    end
    if turn_direction & LOWER_LEFT != 0
      i = 1
      while @board[row+i][col-i] == -color
        @board[row+i][col-i] = color
        i += 1
      end
    end
    if turn_direction & LEFT != 0
      i = 1
      while @board[row][col-i] == -color
        @board[row][col-i] = color
        i += 1
      end
    end
  end

  #ひっくり返せる方向の取得
  def turnable_direction(row, col, color)
    direction = NONE
    #左上
    if @board[row-1][col-1] == -color #相手の色がある場合
      i = 2
      while @board[row-i][col-i] == -color #相手の色が続くまで
        i += 1
      end
      if @board[row-i][col-i] == color #相手の色に続くのが自分の色の場合
        direction |= UPPER_LEFT
      end
    end
    if @board[row-1][col] == -color #上
      i = 2
      while @board[row-i][col] == -color
        i += 1
      end
      if @board[row-i][col] == color
        direction |= UPPER
      end
    end
    if @board[row-1][col+1] == -color #右上
      i = 2
      while @board[row-i][col+i] == -color
        i += 1
      end
      if @board[row-i][col+i] == color
        direction |= UPPER_RIGHT
      end
    end
    if @board[row][col+1] == -color #右
      i = 2
      while @board[row][col+i] == -color
        i += 1
      end
      if @board[row][col+i] == color
        direction |= RIGHT
      end
    end
    if @board[row+1][col+1] == -color #右下
      i = 2
      while @board[row+i][col+i] == -color
        i += 1
      end
      if @board[row+i][col+i] == color
        direction |= LOWER_RIGHT
      end
    end
    if @board[row+1][col] == -color #下
      i = 2
      while @board[row+i][col] == -color
        i += 1
      end
      if @board[row+i][col] == color
        direction |= LOWER
      end
    end
    if @board[row+1][col-1] == -color #左下
      i = 2
      while @board[row+i][col-i] == -color
        i += 1
      end
      if @board[row+i][col-i] == color
        direction |= LOWER_LEFT
      end
    end
    if @board[row][col-1] == -color #左
      i = 2
      while @board[row][col-i] == -color
        i += 1
      end
      if @board[row][col-i] == color
        direction |= LEFT
      end
    end
    return direction
  end

  #ひっくり返せるマスの一覧を取得
  def get_putable_cells(color)
    putable_cells = []
    @board.each_with_index do |row, i|
      row.each_with_index do |col, j|
        if col == EMPTY #空きマス
          turnable_direction = turnable_direction(i, j, color)
          if turnable_direction != NONE #ひっくり返せる方向が存在する=石を置けるマス
            putable_cells.push([i,j]) #座標を格納
          end
        end
      end
    end
    return putable_cells
  end

  def undo(board)
    @board = board
  end

  #石の数のカウント
  def count
    black = 0
    white = 0
    @board.each do |row|
      row.each do |col|
        case col
        when BLACK
          black += 1
        when WHITE
          white += 1
        end
      end
    end
    count = [black, white]
    return count
  end
end