require "./constant"
require "./player"

class Human < Player
  def put_stone(board, turn)
    cell_list = "" #着手可能場所の一覧
    putable_cells = board.get_putable_cells(@color)
    putable_cells.each do |cell|
      cell_list += "(" + COL_NUM.key(cell[1]) + ROW_NUM.key(cell[0]) + ")"
    end
    print(cell_list, "\n")
    print(turn, "手目: ")
    move = gets.chomp! #手の取得
    if move =~ /[a-h][1-8]/
      cell = move.split("")
      col = COL_NUM[cell[0]]
      row = ROW_NUM[cell[1]]
      cell = [row, col]
      if putable_cells.include?(cell)
        return cell
      else
        print("そのマスには打つことはできません\n")
        print("打てるマスは#{cell_list}です\n")
        put_stone(board)
      end
    else
      print("正しいマスを指定してください\n")
      put_stone(board)
    end
  end
end
