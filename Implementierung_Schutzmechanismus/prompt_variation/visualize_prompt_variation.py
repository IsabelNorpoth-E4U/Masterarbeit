# Line diagrams of the guard prompt variation: recall and FPR per guard prompt
# (GP0 = original prompt, GP1 to GP5 = changed prompts), one line per data set.
# Same colors and style as ../visualize_results.py.
#
# Run: python3 visualize_prompt_variation.py

import json
import os
import sys

import matplotlib.pyplot as plt

HERE = os.path.dirname(os.path.abspath(__file__))
MAIN_DIR = os.path.dirname(HERE)
sys.path.insert(0, MAIN_DIR)

import metrics

RESULT_DIR = os.path.join(HERE, "results")
DIAGRAM_DIR = os.path.join(HERE, "results_diagramms")

HSMW_BLUE = "#0069b4"
ENERGY4U_YELLOW = "#ffd23f"
GRAY = "#9a9a9a"
EDGE = "#333333"

PROMPTS = ["GP0", "GP1", "GP2", "GP3", "GP4", "GP5"]
PROMPT_NAMES = ["GP0\n(Original)", "GP1\n(Umgangs-\nsprache)", "GP2\n(Definition)",
                "GP3\n(Rolle)", "GP4\n(Daten-\ntrennung)", "GP5\n(Verschlei-\nerung)"]

# data set, label, color, marker
DATA_SETS = [
    ["eigen", "Eigener Datensatz", HSMW_BLUE, "o"],
    ["bipia", "BIPIA + NotInject", ENERGY4U_YELLOW, "s"],
    ["bipia_obfuscated", "BIPIA, verschleiert", GRAY, "^"],
]


# reads a jsonl file (one JSON per line)
def load_jsonl(file_name):
    rows = []
    with open(file_name, encoding="utf-8") as file:
        for line in file:
            if line.strip() != "":
                rows.append(json.loads(line))
    return rows


# results file of one guard prompt and data set, GP0 comes from the original run
def results_file(prompt_id, data_set):
    if prompt_id == "GP0":
        return os.path.join(MAIN_DIR, "results",
                            "mistral_small4_test_original_" + data_set + "_results.jsonl")
    return os.path.join(RESULT_DIR, "mistral_small4_test_original_" + prompt_id.lower()
                        + "_" + data_set + "_results.jsonl")


def thesis_style():
    plt.rcParams.update({
        "font.size": 9,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.axisbelow": True,
        "axes.grid": True,
        "axes.grid.axis": "y",
        "grid.color": "#dddddd",
        "legend.frameon": False,
        "pdf.fonttype": 42,  # text stays text in the pdf
    })


def save_diagram(figure, name):
    for ending in [".pdf", ".png"]:
        path = os.path.join(DIAGRAM_DIR, name + ending)
        figure.savefig(path, dpi=200, bbox_inches="tight")
        print("Saved as", path)
    plt.close(figure)


# the value with one decimal and a German decimal comma, without ",0"
def value_label(value):
    text = str(round(value, 1)).replace(".", ",")
    if text.endswith(",0"):
        text = text[:-2]
    return text


# one line per data set, the rate (recall or fpr) in percent for every guard prompt
def draw_lines(values, metric_name, y_label, y_max, name):
    figure, ax = plt.subplots(figsize=(16 / 2.54, 7.5 / 2.54))
    x = list(range(len(PROMPTS)))
    for data_set, label, color, marker in DATA_SETS:
        y = values[data_set][metric_name]
        ax.plot(x, y, marker=marker, color=color, markeredgecolor=EDGE, markeredgewidth=0.6,
                linewidth=1.6, markersize=6, label=label)
    # no value labels, the lines lie too close together (the values are printed by the script)
    ax.set_xticks(x)
    ax.set_xticklabels(PROMPT_NAMES, fontsize=8)
    ax.set_ylabel(y_label)
    ax.set_ylim(0, y_max)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.32), ncol=3, fontsize=8)
    save_diagram(figure, name)


thesis_style()
os.makedirs(DIAGRAM_DIR, exist_ok=True)

values = {}
for data_set, label, color, marker in DATA_SETS:
    values[data_set] = {"recall": [], "fpr": []}
    for prompt_id in PROMPTS:
        result = metrics.compute(load_jsonl(results_file(prompt_id, data_set)), "test")
        values[data_set]["recall"].append(result["recall"]["rate"] * 100)
        values[data_set]["fpr"].append(result["fpr"]["rate"] * 100)
        print(prompt_id, data_set, "n =", result["n"],
              "recall", value_label(result["recall"]["rate"] * 100),
              "fpr", value_label(result["fpr"]["rate"] * 100))

draw_lines(values, "recall", "Recall in %", 100, "mistral_small4_test_promptvariation_recall")
draw_lines(values, "fpr", "FPR in %", 20, "mistral_small4_test_promptvariation_fpr")
