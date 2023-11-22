import aiaccel


def main(p):
    y = (p["x1"]**2) - (4.0 * p["x1"]) + (p["x2"]**2) - p["x2"] - (p["x1"] * p["x2"])
    return float(y)


if __name__ == "__main__":
    study = aiaccel.create_study("./config.yaml")
    study.optimize(main)
    study.show_result()

    # study = aiaccel.create_study("./config.yaml")
    # study.optimize(main, n_trials=1)
    # study.evaluate()
    # study.show_result()
