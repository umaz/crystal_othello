require "./constant"
require "./player"

class Human < Player
  def put_stone(board : Board, turn : Int32) : Array(Int32)
    cell_list = "" #着手可能場所の一覧
    putable_cells = board.get_putable_cells(@color)
    putable_cells.each do |cell|
      cell_list += "(" + COL_NUM.key_for(cell[1]) + ROW_NUM.key_for(cell[0]) + ")"
    end
    print(cell_list, "\n")
    print(turn, "手目: ")
    move = gets.to_s.chomp #手の取得
    if move =~ /[a-h][1-8]/
      cell = move.split("")
      col = COL_NUM[cell[0]]
      row = ROW_NUM[cell[1]]
      cell = [row, col]
      if putable_cells.includes?(cell)
        return cell
      else
        print("そのマスには打つことはできません\n")
        print("打てるマスは#{cell_list}です\n")
        put_stone(board, turn)
      end
    else
      print("正しいマスを指定してください\n")
      put_stone(board, turn)
    end
  end
end
