require "./constant"
require "./game"

class Menu
  def initialize
    while true
      print("COMと対戦: 1\n")
      print("二人で対戦: 2\n")
      print("観戦: 3\n")
      print("終了: 4\n")
      mode = gets.chomp.to_i
      case mode
      when COM
        print("COMのレベルを選択してください(1~5):")
        lv = select_lv
        print("手番を選択してください\n")
        print("1: 先手(黒), 2: 後手(白)")
        order = select_order
        case order
        when FIRST
          print("あなたの先手で始めます\n")
        when SECOND
          print("COMの先手で始めます\n")
        end
      when HUMAN
        order = nil
        lv = nil
      when WATCH
        print("先手のレベルを選択してください(1~8):")
          first = select_lv
        print("後手のレベルを選択してください(1~8):")
        second = select_lv
        order = nil
        lv = [first, second]
      when EXIT
        exit
      else
        print("1~8で選択したください\n\n")
        initialize
      end
      Game.new(mode, order, lv)
    end
  end

  def select_lv
    lv = gets.chomp.to_i
    if lv > 8 || lv < 1
      print("1~8で入力してください\n\n")
      lv = select_lv
    end
    return lv
  end

  def select_order
    order = gets.chomp.to_i
    if order != 1 && order != 2
      print("1か2を入力してください\n\n")
      order = select_order
    end
    return order
  end
end

Menu.new