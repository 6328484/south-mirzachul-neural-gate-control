#!/usr/bin/env bash
# Complete pipeline of the article, in order. Run from the repository root.
# About 7 h on two CPU cores. Overwrites the stored policies, training logs, results and figures.
set -euo pipefail

# 1) Neural supervisor on the nominal canal: 5 seeds x 100 generations (about 36 min each)
for s in 0 1 2 3 4; do
  python src/train_nominal.py "$s" 100
done

# 2) 40 further generations: randomised roughness (about 22 min each) and nominal control (about 13 min each)
for s in 0 1 2 3 4; do
  python src/train_continue.py randomised "$s" 40
  python src/train_continue.py nominal "$s" 40
done

# 3) Full-control benchmark for the four test scenarios (about 15 min each)
python src/benchmark.py

# 4) Evaluation of all strategies (about 10 min)
python src/evaluate.py > results/evaluation_log.txt

# 5) Tables and figures
python src/make_fig_canal.py
python src/fig_architecture.py
python src/make_figures.py
