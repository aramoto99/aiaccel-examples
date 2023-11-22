#import aiaccel
from aiaccel import Run

def main(p):
    y = (p["x1"]**2) - (4.0 * p["x1"]) + (p["x2"]**2) - p["x2"] - (p["x1"] * p["x2"])
    print("aaaa!")
    print(f"y={y}")
    return float(y)


if __name__ == "__main__":
    #run = aiaccel.Run()
    run = Run()
    run.execute_and_report(main)
