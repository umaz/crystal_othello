# crystal_othello
CUIのオセロ Rubyで作成したもののCrystal版

## crystalのコンパイル
crystal build --release main.cr

## モード
* COMと対戦
* 2人で対戦
* COMの対戦を観戦

## COMのレベル
1. ランダム
2. スコアの高くなるマスに打つ
3. 返したスコアが高くなるマスに打つ
4. Lv3の評価方法で5手先まで読む
5. 基本はLv4で枝刈りによって6手先まで読む
6. 47手以降完全よみ
7. 44手以降勝敗読み
8. 盤のスコアだけでなく着手可能手数も考慮
詳細(Ruby版)
https://scrapbox.io/umaz/Rubyでオセロ~その1~
