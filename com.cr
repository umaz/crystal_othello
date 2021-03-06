require "./constant"
require "./player"

class Com < Player
  def initialize(color : Int32, lv : Int32)
    super(color) #親クラスのメソッド呼び出し
    @lv = lv
  end

  def put_stone(board : Board, turn : Int32) : Array(Int32)
    case @lv
    when 1
      cell = lv1(board)
    when 2
      cell = lv2(board)
    when 3
      cell = lv3(board)
    when 4
      cell = lv4(board)
    when 5
      cell = lv5(board)
    when 6
      cell = lv6(board, turn)
    when 7
      cell = lv7(board, turn)
    when 8
      cell = lv8(board, turn)
    else
      cell = [0,0]
    end
    row = ROW_NUM.key_for(cell[0])
    col = COL_NUM.key_for(cell[1])
    move = col + row
    print(turn, "手目: ", move)
    return cell
  end

  private def lv1(board : Board) : Array(Int32)
    putable_cells = get_putable_cells(board)
    put_cell = putable_cells.sample #空きますからランダムに1つ取得
    return put_cell
  end

  #BOARD_SCOREのもっとも大きくなるマスに石を打つ
  private def lv2(board : Board) : Array(Int32)
    putable_cells = get_putable_cells(board)
    best_score, candicate_cells = set_default_value
    putable_cells.each do |cell|
      score = BOARD_SCORE[cell[0]][cell[1]]
      candicate_cells, best_score = evaluate(cell, score, best_score, candicate_cells)
    end
    put_cell = select_com_move(candicate_cells)
    return put_cell
  end

  #BOARD_SCOREの合計が最も大きくなるマスに打つ
  private def lv3(board : Board) : Array(Int32)
    putable_cells = get_putable_cells(board)
    best_score, candicate_cells = set_default_value
    putable_cells.each do |cell|
      undo = board.board.clone #深いコピー
      board.reverse(cell[0], cell[1], @color)
      score = 0
      board.board.each_with_index do |row, i|
        row.each_with_index do |col, j|
          if col == @color
            score += BOARD_SCORE[i][j]
          end
        end
      end
      board.undo(undo)
      candicate_cells, best_score = evaluate(cell, score, best_score, candicate_cells)
    end
    put_cell = select_com_move(candicate_cells)
    return put_cell
  end

  #depth手先まで読む
  private def lv4(board : Board) : Array(Int32)
    putable_cells = get_putable_cells(board)
    best_score, candicate_cells = set_default_value
    depth = 5 #先読みの深さ
    putable_cells.each do |cell|
      undo = board.board.clone #深いコピー
      board.reverse(cell[0], cell[1], @color)
      case status(board, -@color, depth)
      when FINISH
        score = board_score(board)
      when PASS
        score = minmax(board, depth-1, @color)
      when MOVE
        score = minmax(board, depth-1, -@color)
      else
        score = 0
      end
      board.undo(undo)
      candicate_cells, best_score = evaluate(cell, score, best_score, candicate_cells)
    end
    put_cell = select_com_move(candicate_cells)
    return put_cell
  end

  #alphabeta方で読みの高速化
  private def lv5(board : Board) : Array(Int32)
    putable_cells = get_putable_cells(board)
    best_score, candicate_cells, alpha, beta = set_default_value
    depth = 7 #先読みの深さ
    putable_cells.each do |cell|
      undo = board.board.clone #深いコピー
      board.reverse(cell[0], cell[1], @color)
      case status(board, -@color, depth)
      when FINISH
        score = board_score(board)
      when PASS
        score = alphabeta(board, depth-1, @color, alpha, beta, BOARD)
      when MOVE
        score = alphabeta(board, depth-1, -@color, alpha, beta, BOARD)
      else
        score = 0
      end
      board.undo(undo)
      candicate_cells, best_score = evaluate(cell, score, best_score, candicate_cells)
    end
    put_cell = select_com_move(candicate_cells)
    return put_cell
  end

  # 47手から完全読み
  private def lv6(board : Board, turn : Int32) : Array(Int32)
    putable_cells = get_putable_cells(board)
    best_score, candicate_cells, alpha, beta = set_default_value
    depth = -1 #先読みの深さ
    if turn > 46
      score_type = PERFECT
    else
      score_type = BOARD
      depth = 6
    end
    putable_cells.each do |cell|
      undo = board.board.clone #深いコピー
      board.reverse(cell[0], cell[1], @color)
      case status(board, -@color, depth)
      when FINISH
        score = perfect_score(board)
      when PASS
        score = alphabeta(board, depth-1, @color, alpha, beta, score_type)
      when MOVE
        score = alphabeta(board, depth-1, -@color, alpha, beta, score_type)
      else
        score = 0
      end
      board.undo(undo)
      candicate_cells, best_score = evaluate(cell, score, best_score, candicate_cells)
    end
    put_cell = select_com_move(candicate_cells)
    return put_cell
  end

  # 44手で勝敗読み
  private def lv7(board : Board, turn : Int32) : Array(Int32)
    putable_cells = get_putable_cells(board)
    best_score, candicate_cells, alpha, beta = set_default_value
    depth = -1 #先読みの深さ
    if turn > 46
      score_type = PERFECT
    elsif turn > 43
      score_type = WINNER
    else
      score_type = BOARD
      depth = 6
    end
    putable_cells.each do |cell|
      undo = board.board.clone #深いコピー
      board.reverse(cell[0], cell[1], @color)
      case status(board, -@color, depth)
      when FINISH
        score = perfect_score(board)
      when PASS
        score = alphabeta(board, depth-1, @color, alpha, beta, score_type)
      when MOVE
        score = alphabeta(board, depth-1, -@color, alpha, beta, score_type)
      else
        score = 0
      end
      board.undo(undo)
      candicate_cells, best_score = evaluate(cell, score, best_score, candicate_cells)
    end
    put_cell = select_com_move(candicate_cells)
    return put_cell
  end

  # BOARD_SCOREだけでなく着手可能手数も考慮に入れる
  private def lv8(board : Board, turn : Int32) : Array(Int32)
    putable_cells = get_putable_cells(board)
    best_score, candicate_cells, alpha, beta = set_default_value
    depth = -1 #先読みの深さ
    if turn > 46
      score_type = PERFECT
    elsif turn > 43
      score_type = WINNER
    else
      score_type = HANDS
      depth = 6
    end
    putable_cells.each do |cell|
      undo = board.board.clone #深いコピー
      board.reverse(cell[0], cell[1], @color)
      case status(board, -@color, depth)
      when FINISH
        score = perfect_score(board)
      when PASS
        score = alphabeta(board, depth-1, @color, alpha, beta, score_type)
      when MOVE
        score = alphabeta(board, depth-1, -@color, alpha, beta, score_type)
      else
        score = 0
      end
      board.undo(undo)
      candicate_cells, best_score = evaluate(cell, score, best_score, candicate_cells)
    end
    put_cell = select_com_move(candicate_cells)
    return put_cell
  end

  private def get_putable_cells(board)
    putable_cells = board.get_putable_cells(@color)
    print(cell_list(putable_cells), "\n")
    return putable_cells
  end

  private def set_default_value
    best_score = -999999999
    candicate_cells = [[0,0]]
    alpha = -999999999
    beta = 999999999
    return best_score, candicate_cells, alpha, beta
  end

  private def evaluate(cell, score : Int32, best_score : Int32, candicate_cells)
    print(COL_NUM.key_for(cell[1]) + ROW_NUM.key_for(cell[0]), ": ", score, "\n")
    if score > best_score
      candicate_cells = [cell]
      best_score = score
    elsif score == best_score
      candicate_cells.push(cell)
    end
    return candicate_cells, best_score
  end

  private def minmax(board, depth, color)
    best_score = 999999999
    putable_cells = board.get_putable_cells(color)
    putable_cells.each do |cell|
      undo = board.board.clone #深いコピー
      board.reverse(cell[0], cell[1], color)
      case status(board, -color, depth)
      when FINISH
        score = board_score(board)
      when PASS
        score = minmax(board, depth-1, color)
      when MOVE
        score = minmax(board, depth-1, -color)
      else
        score = 0
      end
      board.undo(undo)
      #スコアの選択(αβ法)
      if best_score == 999999999
        best_score = score
      end
      if color == @color && score > best_score
        best_score = score
      end
      if color == -@color && score < best_score
        best_score = score
      end
    end
    return best_score
  end

  private def alphabeta(board, depth, color, alpha, beta, score_type) : Int32
    best_score = 999999999
    putable_cells = board.get_putable_cells(color)
    putable_cells.each do |cell|
      undo = board.board.clone #深いコピー
      board.reverse(cell[0], cell[1], color)
      case status(board, -color, depth)
      when FINISH
        case score_type
        when PERFECT
          score = perfect_score(board)
        when WINNER
          score = winner_score(board)
        when BOARD
          score = board_score(board)
        when HANDS
          score = board_score(board)
          if color == @color
            score += 5 * putable_cells.size
          else
            score -= 5 * putable_cells.size
          end
        else
          score = 0
        end
      when PASS
        score = alphabeta(board, depth-1, color, alpha, beta, score_type)
      when MOVE
        score = alphabeta(board, depth-1, -color, alpha, beta, score_type)
      else
        score = 0
      end
      board.undo(undo)
      #スコアの選択(αβ法)
      if best_score == 999999999
        best_score = score
      end
      if color == @color
        if score > best_score
          best_score = score
        end
        if best_score > alpha
          alpha = best_score
        end
        if alpha >= beta
          return alpha
        end
      end
      if color == -@color
        if score < best_score
          best_score = score
        end
        if best_score < beta
          beta = best_score
        end
        if alpha >= beta
          return beta
        end
      end
    end
    return best_score
  end

  private def board_score(board) : Int32
    score = 0
    #スコアの算出
    board.board.each_with_index do |row, i|
      row.each_with_index do |col, j|
        if col == @color
          score += BOARD_SCORE[i][j]
        end
      end
    end
    return score
  end

  private def winner_score(board) : Int32
    #スコアの算出
    result = board.count
    score = @color * (result[0] - result[1]) #石差
    if score > 0
      return 1
    elsif score < 0
      return -1
    else
      return 0
    end
  end

  private def perfect_score(board) : Int32
    #スコアの算出
    result = board.count
    score = @color * (result[0] - result[1]) #石差
    return score
  end

  #状態判定
  private def status(board, color, depth)
    if depth == 0
      return FINISH
    else
      if board.get_putable_cells(color).size == 0
        if board.get_putable_cells(-color).size == 0
          return FINISH
        else
          return PASS
        end
      else
        return MOVE
      end
    end
  end
  
  private def cell_list(putable_cells)
    cell_list = "" #着手可能場所の一覧
    putable_cells.each do |cell|
      cell_list += "(" + COL_NUM.key_for(cell[1]) + ROW_NUM.key_for(cell[0]) + ")"
    end
    return cell_list
  end

  private def select_com_move(candicate_cells)
    cell = candicate_cells.sample
    return cell
  end  
end
