require 'benchmark'
require "./game"

#[引き分け数, 先手勝ち数, 後手勝ち数]
result = [0,0,0] #1回目
reverse_result = [0,0,0] #入れ替え後

print("AI1:")
first = gets.chomp.to_i
print("AI2:")
second = gets.chomp.to_i
print("対局回数:")
n = gets.chomp!.to_i

benchmark = Benchmark.measure do
  n.times do
    winner = Game.new(3, nil, [first, second])
    result[winner.end_game] += 1
  end
  # 順番を入れ替える
  n.times do
    winner = Game.new(3, nil, [second, first])
    reverse_result[winner.end_game] += 1
  end
end

puts ""
#AI1の勝ち数はresultの先手勝ち数とreverse_resultの後手勝ち数
print("AI1(レベル#{first}):#{result[1]+reverse_result[-1]}勝(先手:#{result[1]}勝,後手#{reverse_result[-1]}勝)\n")
print("AI2(レベル#{second}):#{result[-1]+reverse_result[1]}勝(先手:#{reverse_result[1]}勝,後手#{result[-1]}勝)\n")
print("#{result[0]+reverse_result[0]}引き分け\n")

puts ""
puts Benchmark::CAPTION
puts benchmark