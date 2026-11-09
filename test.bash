#!/bin/bash
# SPDX-FileCopyrightText: 2026 Your Name
# SPDX-License-Identifier: BSD-3-Clause

ng () {
    echo "${1}行目が違うよ"
    res=1
}

res=0
cmd=./beanmatch

### 正常系 ###
# 完全一致なら一致度100
out=$(echo "acidity=5 bitterness=1 body=2 sweetness=4 aroma=5" | "$cmd")
[ "${out}" = $'エチオピア・イルガチェフェ\t100' ] || ng "$LINENO"

# 日本語のキーも使える
out=$(echo "苦味=5 コク=5" | "$cmd")
[ "${out}" = $'ベトナム・ロブスタ\t100' ] || ng "$LINENO"

# 焙煎度で絞り込める
out=$(echo "苦味=5" | "$cmd" -r light)
[ "${out}" = $'エチオピア・シダモ\t25' ] || ng "$LINENO"

# -n で出力数を変えられる
out=$(echo "酸味=3" | "$cmd" -n 3 | wc -l)
[ "${out}" = 3 ] || ng "$LINENO"

# 複数行の入力は1行ずつ処理される
out=$(printf "酸味=5\n苦味=5\n" | "$cmd" | wc -l)
[ "${out}" = 2 ] || ng "$LINENO"

# コメントと空行は無視される
out=$(printf "# comment\n\n酸味=5\n" | "$cmd" | wc -l)
[ "${out}" = 1 ] || ng "$LINENO"

# 一覧表示
out=$("$cmd" -l | wc -l)
[ "${out}" = 11 ] || ng "$LINENO"

# 空入力なら何も出さずに正常終了
out=$(printf "" | "$cmd")
[ "$?" = 0 ] || ng "$LINENO"
[ "${out}" = "" ] || ng "$LINENO"

### 異常系 ###
# 範囲外の値
out=$(echo "酸味=9" | "$cmd" 2> /dev/null)
[ "$?" = 1 ] || ng "$LINENO"
[ "${out}" = "" ] || ng "$LINENO"

# 不明な項目
out=$(echo "塩味=3" | "$cmd" 2> /dev/null)
[ "$?" = 1 ] || ng "$LINENO"
[ "${out}" = "" ] || ng "$LINENO"

# key=value になっていない
out=$(echo "酸味" | "$cmd" 2> /dev/null)
[ "$?" = 1 ] || ng "$LINENO"

# エラーは標準エラー出力に出る
out=$(echo "酸味=9" | "$cmd" 2>&1 > /dev/null)
[ "${out}" != "" ] || ng "$LINENO"

# 不正な行があっても他の行は処理し、終了ステータスは1
out=$(printf "酸味=9\n酸味=5\n" | "$cmd" 2> /dev/null | wc -l)
[ "${out}" = 1 ] || ng "$LINENO"
printf "酸味=9\n酸味=5\n" | "$cmd" > /dev/null 2>&1
[ "$?" = 1 ] || ng "$LINENO"

# 不正なオプション
"$cmd" -n 0 < /dev/null 2> /dev/null
[ "$?" != 0 ] || ng "$LINENO"
"$cmd" -n abc < /dev/null 2> /dev/null
[ "$?" != 0 ] || ng "$LINENO"
"$cmd" -r blonde < /dev/null 2> /dev/null
[ "$?" != 0 ] || ng "$LINENO"

[ "${res}" = 0 ] && echo OK
exit $res
