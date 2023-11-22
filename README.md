# [new-aiaccel](https://github.com/aramoto99/new-aiaccel) のための example


# new-aiaccel インストール
~~~ bash
git clone git@github.com:aramoto99/new-aiaccel.git
cd new-aiaccel
pip install -e .
~~~

# example リポジトリのクローン
~~~ bash
git clone git@github.com:aramoto99/aiaccel-examples.git
~~~

- ## example の構成
  - benchmark - 標準的な2変数関数の最適化の例
  - mpi - MPI を使用する場合の例
  - ps - 粒子群最適化の例
  - resnet_cifar10 - ResNet のハイパーパラメータ最適化の例
  - schwefel - Schwefel 関数の最適化の例
  - schwefel_fortran - Schwefel 関数の最適化の例 (Fortran)
  - sphere - Sphere 関数の最適化の例
  - styblinski-tang - Styblinski-Tang 関数の最適化の例
  - vlmop2 - VLMOP2 多目的最適化の例

# 使い方

## HPC (ABCI)
- user.py
~~~ python
import aiaccel


def main(p):
    y = (p["x1"]**2) - (4.0 * p["x1"]) + (p["x2"]**2) - p["x2"] - (p["x1"] * p["x2"])
    return float(y)


if __name__ == "__main__":
    run = aiaccel.Run()
    run.execute_and_report(main)
~~~

- config.yaml
~~~ yaml
generic:
  # aiaccel_dir: ""
  # venv_dir: ""
  workspace: ./work
  job_command: python user.py
  python_file: ./user.py
  function: main
  enabled_variable_name_argumentation: True
  main_loop_sleep_seconds: 0.01
  logging_level: info

resource:
  type: abci
  num_workers: 4

ABCI:
  group: your-group-id
  job_execution_options: ""
  # job_script_preamble_path: ./job_script_preamble.sh
  job_script_preamble: |
    #!/bin/bash

    #$-l rt_C.small=1
    #$-j y
    #$-cwd

    source /etc/profile.d/modules.sh
    module load gcc/12.2.0
    module load python/3.11

job_setting:
    job_timeout_seconds: 600
    max_failure_retries: 0
    trial_id_digits: 7

optimize:
  search_algorithm: aiaccel.optimizer.NelderMeadOptimizer
  goal: minimize
  trial_number: 30
  rand_seed: 42
  parameters:
    -
      name: x1
      type: uniform_float
      lower: 0.0
      upper: 5.0
      initial: [1.1, 1.2, 1.3]
    -
      name: x2
      type: uniform_float
      lower: 0.0
      upper: 5.0
      initial: [2.1, 2.2, 2.3]
~~~

- 実行
~~~ bash
aiaccel-start --config config.yaml --clean
~~~


## local
- resource の type を local にする

~~~ yaml
resource:
  type: local
  num_workers: 4
  ...
~~~

- 実行
~~~ bash
aiaccel-start --config config.yaml --clean
~~~


## local (簡易モード)

並列実行不可

- user.py
~~~ python
import aiaccel


def main(p):
    y = (p["x1"]**2) - (4.0 * p["x1"]) + (p["x2"]**2) - p["x2"] - (p["x1"] * p["x2"])
    return float(y)


if __name__ == "__main__":
    study = aiaccel.create_study("./config.yaml")
    study.optimize(main)
    study.evaluate()
    study.show_result()
~~~

- 実行
~~~ bash
python user.py
~~~


## MPI
- resource の type を mpi にする
- resource の mpi に関する項目を設定する

~~~ yaml
resource:
  type: abci
  num_workers: 4
  mpi_npernode: 4
  mpi_bat_rt_type: F
  mpi_bat_rt_num: 1
  mpi_bat_h_rt: "72:00:00"
  mpi_bat_file: ./qsub.sh
  mpi_hostfile: ./hostfile
  mpi_gpu_mode: True
  mpi_bat_make_file: True
  ...
~~~

- 実行
~~~ bash
aiaccel-start --config config.yaml --clean
~~~

# オプショナル

## clean
`--clean` オプションを指定すると、既にワークスペースのディレクトリが存在する場合、ワークスペースを削除する。
~~~ bash
aiaccel-start --config config.yaml --clean
~~~

## resume
`--resume` オプションを指定すると、前回の実行結果を読み込み、続きから実行する。 `--resume` の後には、任意のトライアルIDを指定する。
~~~ bash
aiaccel-start --config config.yaml --resume 5
~~~


<hr>

# 設定項目の解説
## generic
- aiaccel_dir: aiaccel のインストール先ディレクトリ (オプショナル)。aiaccel をインストールせずに実行する場合、この項目に aiaccel のディレクトリを指定する。実行するときは、`PYTHONPATH` に `aiaccel_dir` を追加する。
- venv_dir: 仮想環境(venv)のインストール先ディレクトリ (オプショナル)
- workspace: ワークスペースのディレクトリ。`aiaccel-start` 実行時に、このディレクトリが作成される。最適化の結果は、このディレクトリ内に保存される。
- job_command: ジョブの実行コマンド。`python user.py` のように指定する。
- python_file: 実行する python ファイル。`./user.py` のように指定する。この項目は、`resource` が `python_local` の場合のみ有効。
- function: python_file で指定したファイル内の、最適化対象の関数。この項目は、`resource` が `python_local` の場合のみ有効。
- enabled_variable_name_argumentation: `job_command` に変数名を指定するかどうか。`True` なら `--x1=1.0 --x2=2.0` のように指定する。`False` なら `1.0 2.0` のように指定する。
- main_loop_sleep_seconds: メインループのスリープ時間
- logging_level:
  
  ----
  | ログレベル | 備考 |
  | ---- | ---- |
  | debug | デバッグ用 |
  | info | 通常のログ |
  | warning | 警告 |
  | error | エラー |
  | critical | クリティカル |


## resource
- type: リソースの種類。`abci`、 `local`、`python_local`, `mpi` を指定する。
  ----
  | リソース | 指定方法 | 備考 |
  | ---- | ---- | ---- |
  | ABCI | `abci` | ABCI で実行する場合に指定する |
  | MPI | `mpi` | MPI で実行する場合に指定する。このモードでは、ABCI でのみ実行可能 |
  | ローカル | `local` | ローカルで実行する場合に指定する |
  | ローカル (Python) | `python_local` | 最適化対象が `python` プログラムである場合、このモードを使用可能。`local`よりも高速に実行可能 |

- num_workers: 並列実行時のワーカー数
- mpi_npernode: mpi でのノードあたりのワーカー数。`type` が `mpi` の場合のみ有効。
- mpi_bat_rt_type: 資源タイプの設定。typeが `mpi` かつ、ABCIで実行する場合のみ有効。`F` か `G.large`, `G.small`, `C.large`, `C.small` を指定する。
- mpi_bat_rt_num: ノード数の設定。`type` が `mpi` かつ、ABCIで実行する場合のみ有効。
- mpi_bat_h_rt: 実行時間の設定。`type` が `mpi` かつ、ABCIで実行する場合のみ有効。ジョブの実行時間が指定した時間を超過した場合、ジョブは強制終了されます。
- mpi_bat_file: ジョブスクリプトの生成先。`type` が `mpi` かつ、ABCIで実行する場合のみ有効。
- mpi_hostfile: ホストファイルの生成先。`type` が `mpi` かつ、ABCIで実行する場合のみ有効。
- mpi_gpu_mode: GPUモードの設定。`type` が `mpi` かつ、ABCIで実行する場合のみ有効。
- mpi_bat_make_file: ジョブスクリプトを生成するかどうか。`type` が `mpi` かつ、ABCIで実行する場合のみ有効。

## ABCI
本項目は、`resource` が `abci` の場合のみ有効。
- group: グループID
- job_execution_options: ジョブ実行オプション。
- job_script_preamble_path: ジョブスクリプトの先頭に追加するコマンドを記述したファイルのパス。
- job_script_preamble: ジョブスクリプトの先頭に追加するコマンド。`job_script_preamble_path` と `job_script_preamble` の両方が指定されている場合、`job_script_preamble_path` が優先される。

## job_setting
- job_timeout_seconds: ジョブのタイムアウト時間
- max_failure_retries: ジョブの最大失敗リトライ回数
- trial_id_digits: トライアルIDの桁数

## optimize
- search_algorithm: 探索アルゴリズム
  
  ----
  | アルゴリズム | 指定方法 |
  | ---- | ---- |
  | ネルダーミード | `aiaccel.optimizer.NelderMeadOptimizer` |
  | 粒子群最適化 | `aiaccel.optimizer.ParticleSwarmOptimizer` |
  | ランダム | `aiaccel.optimizer.RandomSearchOptimizer` |
  | ソボル列 | `aiaccel.optimizer.SobolOptimizer` |
  | グリッドサーチ | `aiaccel.optimizer.GridOptimizer` |
  | TPE | `aiaccel.optimizer.TpeOptimizer` |
  

- goal: 目的関数の目標値。`minimize` か `maximize` を指定する。
- trial_number: トライアル数
- rand_seed: 乱数シード。項目がない場合は `numpy` のデフォルト設定が使用される。
- num_particles: 粒子群最適化の粒子数。`search_algorithm` が `ParticleSwarmOptimizer` の場合のみ有効。
- inertia_weight: 粒子群最適化の慣性重み。`search_algorithm` が `ParticleSwarmOptimizer` の場合のみ有効。
- cognitive_weight: 粒子群最適化の認知重み。`search_algorithm` が `ParticleSwarmOptimizer` の場合のみ有効。
- social_weight: 粒子群最適化の社会的重み。`search_algorithm` が `ParticleSwarmOptimizer` の場合のみ有効。
- parameters:
  - name: パラメータ名
  - type:

    ----
    | パラメータの種類 | 指定方法 | 備考 |
    | ---- | ---- | ---- |
    | 実数値 | `uniform_float` | - |
    | 整数値 | `uniform_int` | - |
    | カテゴリー変数 | `categorical` | - |
    | 序数 | `ordinal` | - |

    `uniform_float`, `uniform_int`, `categorical`, `ordinal`のいずれか。
  - lower: 下限値
  - upper: 上限値
  - initial: 初期値。[] で囲むと複数指定可能。
  - choices: カテゴリー変数の場合のみ有効。カテゴリーのリスト。[] で指定。
  - sequence: 序数の場合のみ有効。序数のリスト。[] で指定。
  - log: 対数スケールを使用するかどうか。`True` か `False` を指定する。
  - step: `search_algorithm` が `GridOptimizer` の場合のみ有効。グリッドサーチのステップ数。

