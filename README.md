### [new-aiaccel](https://github.com/aramoto99/new-aiaccel) のための example


## 使い方
### HPC
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
  workspace: ./work
  job_command: python user.py
  python_file: ./user.py
  function: main
  enabled_variable_name_argumentation: True
  main_loop_sleep_seconds: 0.01
  logging_level: info

resource:
  # type: abci
  type: local
  num_workers: 4

ABCI:
  group: your-group-name
  job_script_preamble: ./job_script_preamble.sh
  job_execution_options: ""

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
