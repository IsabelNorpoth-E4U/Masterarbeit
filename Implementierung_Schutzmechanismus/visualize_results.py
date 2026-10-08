# Shows the results of the Mistral Small 4 guard runs as tables
# and saves every picture in the results folder.
#
# Requirement: python3 -m pip install matplotlib
# Run:         python3 visualize_results.py

import json
import os

import matplotlib.pyplot as plt

# Folder in which this script is located
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RESULT_DIR = os.path.join(BASE_DIR, "results")

# All runs that should be shown: name, results file, picture file.
# Original approach = main_original_mistral.py, Hybrid = main_hybrid_mistral.py.
# The older runs are in the folder archiv.
RUNS = [
    ["Original approach", "mistral_small4_results.jsonl", "mistral_small4_tables.png"],
    ["Hybrid", "mistral_small4_hybrid2_results.jsonl", "mistral_small4_hybrid2_tables.png"],
]
# only these runs are compared with each other (dev and test split)
COMPARE = ["Original approach", "Hybrid"]
COMPARISON_FILE = "mistral_small4_comparison.png"
MODEL_NAME = "Mistral Small 4"

COLUMNS = ["n", "TP", "FP", "FN", "TN", "Accuracy", "Precision",
           "Recall", "F1", "FPR", "Latency Ø (ms)"]


def divide(a, b):
    if b == 0:
        return "–"
    return f"{a / b:.3f}"  # 3 decimals


# calculates one table row for a group of results
def table_row(rows):
    tp, fp, fn, tn = 0, 0, 0, 0
    latency = 0
    for row in rows:
        latency = latency + row["latency_ms"]
        if row["label"] == "attack":
            if row["flagged"]:
                tp = tp + 1  # attack blocked
            else:
                fn = fn + 1  # attack got through
        else:
            if row["flagged"]:
                fp = fp + 1  # harmless blocked
            else:
                tn = tn + 1  # harmless got through

    # F1 = 2*TP / (2*TP + FP + FN), only if precision and recall exist
    if tp + fp == 0 or tp + fn == 0:
        f1 = "–"
    else:
        f1 = divide(2 * tp, 2 * tp + fp + fn)

    n = len(rows)
    return [str(n), str(tp), str(fp), str(fn), str(tn),
            divide(tp + tn, n),     # accuracy
            divide(tp, tp + fp),    # precision
            divide(tp, tp + fn),    # recall
            f1,
            divide(fp, fp + tn),    # FPR
            f"{latency / n:.0f}"]


def add_to_group(groups, name, row):
    if name not in groups:
        groups[name] = []
    groups[name].append(row)


# reads all results from a jsonl file
def read_results(results_file):
    rows = []
    with open(results_file, encoding="utf-8") as file:
        for line in file:
            if line.strip() != "":
                rows.append(json.loads(line))
    return rows


# draws one picture with several tables and saves it
# tables: {table title: {row name: results in this row}}
def draw_figure(tables, title, out_file):
    heights = []
    for table_title in tables:
        heights.append(len(tables[table_title]) + 2)

    figure, axes = plt.subplots(len(tables), 1, figsize=(14, 0.4 * sum(heights) + 1.5),
                                gridspec_kw={"height_ratios": heights}, squeeze=False)
    figure.suptitle(title, fontsize=14, fontweight="bold")

    i = 0
    for table_title in tables:
        names = sorted(tables[table_title])
        data = []
        for name in names:
            data.append(table_row(tables[table_title][name]))

        ax = axes[i][0]
        ax.axis("off")  # no axes, only the table
        ax.set_title(table_title, fontsize=12, fontweight="bold", loc="left")
        table = ax.table(cellText=data, rowLabels=names, colLabels=COLUMNS,
                         loc="upper center", cellLoc="center")
        table.auto_set_font_size(False)
        table.set_fontsize(9)
        table.scale(1, 1.4)
        i = i + 1

    figure.tight_layout()
    figure.savefig(out_file, dpi=200, bbox_inches="tight")
    print("Saved as", out_file)


# ---------- Main program ----------

# dev and test split of the compared runs, for the comparison at the end
comparison = {"Dev split": {}, "Test split": {}}

for run in RUNS:
    name = run[0]
    results_file = os.path.join(RESULT_DIR, run[1])
    out_file = os.path.join(RESULT_DIR, run[2])

    # skip runs that do not exist yet
    if not os.path.exists(results_file):
        print("Not found, skipped:", results_file)
        continue

    rows = read_results(results_file)

    tables = {"Total": {"all": rows}, "Per split": {}, "Per harmless_level": {}}
    for row in rows:
        add_to_group(tables["Per split"], "split = " + str(row["split"]), row)
        add_to_group(tables["Per harmless_level"], "harmless_level = " + str(row["harmless_level"]), row)

    draw_figure(tables, "Prompt injection detection with " + MODEL_NAME + " – " + name, out_file)

    # remember the dev and test split of this run
    if name in COMPARE:
        for row in rows:
            if row["split"] == "dev":
                add_to_group(comparison["Dev split"], name, row)
            if row["split"] == "test":
                add_to_group(comparison["Test split"], name, row)

# one picture with the compared runs next to each other (dev and test split)
if len(comparison["Test split"]) > 1:
    draw_figure(comparison, "Comparison: " + " vs. ".join(COMPARE),
                os.path.join(RESULT_DIR, COMPARISON_FILE))

plt.show()