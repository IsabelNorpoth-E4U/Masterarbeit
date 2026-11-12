# Bar diagrams of the guard prompt variation: recall and FPR per guard prompt
# (GP0 = original prompt, GP1 to GP5 = changed prompts), one bar per data set.
# Also a LaTeX table with recall and FPR (with Wilson confidence interval) per guard prompt.
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


# grouped bars: one group per guard prompt, one bar per data set, the rate (recall or fpr)
# in percent. Bars instead of lines, because the guard prompts are independent variants
# and not a sequence. Same style as draw_grouped_bars in ../visualize_results.py.
def draw_bars(values, metric_name, y_label, y_max, name):
    figure, ax = plt.subplots(figsize=(16 / 2.54, 7.5 / 2.54))
    bar_width = 0.8 / len(DATA_SETS)
    for d, (data_set, label, color, marker) in enumerate(DATA_SETS):
        positions = [g - 0.4 + bar_width / 2 + d * bar_width for g in range(len(PROMPTS))]
        heights = values[data_set][metric_name]
        # a small gap between the bars (width * 0.9)
        bars = ax.bar(positions, heights, bar_width * 0.9, label=label,
                      color=color, edgecolor=EDGE, linewidth=0.6)
        # value above the bar, a bar with 0 % cannot be seen but still gets its "0"
        for bar, height in zip(bars, heights):
            ax.text(bar.get_x() + bar.get_width() / 2, height + y_max * 0.015,
                    value_label(height), ha="center", va="bottom", fontsize=6, color=EDGE)
    ax.set_xticks(range(len(PROMPTS)))
    ax.set_xticklabels(PROMPT_NAMES, fontsize=8)
    ax.set_ylabel(y_label)
    ax.set_ylim(0, y_max * 1.1)
    ax.set_yticks(range(0, y_max + 1, y_max // 5))
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.32), ncol=3, fontsize=8)
    save_diagram(figure, name)


# 0.731 -> '73{,}1' (German decimal comma)
def percent_tex(rate):
    return f"{100 * rate:.1f}".replace(".", "{,}")


# rate with confidence interval, the interval small and gray (as in ../visualize_results.py)
def share_tex(share):
    return (percent_tex(share["rate"]) + r"\,\% {\scriptsize\color{gray}["
            + percent_tex(share["ci_low"]) + "; " + percent_tex(share["ci_high"]) + "]}")


# one row per guard prompt, recall and FPR for every data set
def write_table(shares, name):
    lines = [
        r"\resizebox{\textwidth}{!}{%",
        r"\begin{tabular}{l rr rr rr}",
        r"\toprule",
    ]
    header = [""]
    rules = []
    for i, (data_set, label, color, marker) in enumerate(DATA_SETS):
        header.append(r"\multicolumn{2}{c}{\textbf{" + label + "}}")
        rules.append(r"\cmidrule(lr){" + str(2 + 2 * i) + "-" + str(3 + 2 * i) + "}")
    lines.append(" & ".join(header) + r" \\")
    lines.append("".join(rules))
    lines.append(r"\textbf{Guard-Prompt}" + r" & \textbf{Recall} & \textbf{FPR}" * len(DATA_SETS)
                 + r" \\")
    lines.append(r"\midrule")
    for i, prompt_id in enumerate(PROMPTS):
        cells = [PROMPT_NAMES[i].replace("-\n", "").replace("\n", " ")]
        for data_set, label, color, marker in DATA_SETS:
            cells.append(share_tex(shares[data_set]["recall"][i]))
            cells.append(share_tex(shares[data_set]["fpr"][i]))
        lines.append(" & ".join(cells) + r" \\")
    lines.append(r"\bottomrule")
    lines.append(r"\end{tabular}}")
    path = os.path.join(DIAGRAM_DIR, name + ".tex")
    with open(path, "w", encoding="utf-8") as file:
        file.write("\n".join(lines) + "\n")
    print("Saved as", path)


thesis_style()
os.makedirs(DIAGRAM_DIR, exist_ok=True)

values = {}
shares = {}
for data_set, label, color, marker in DATA_SETS:
    values[data_set] = {"recall": [], "fpr": []}
    shares[data_set] = {"recall": [], "fpr": []}
    for prompt_id in PROMPTS:
        result = metrics.compute(load_jsonl(results_file(prompt_id, data_set)), "test")
        values[data_set]["recall"].append(result["recall"]["rate"] * 100)
        values[data_set]["fpr"].append(result["fpr"]["rate"] * 100)
        shares[data_set]["recall"].append(result["recall"])
        shares[data_set]["fpr"].append(result["fpr"])
        print(prompt_id, data_set, "n =", result["n"],
              "recall", value_label(result["recall"]["rate"] * 100),
              "fpr", value_label(result["fpr"]["rate"] * 100))

draw_bars(values, "recall", "Recall in %", 100, "mistral_small4_test_promptvariation_recall")
draw_bars(values, "fpr", "FPR in %", 20, "mistral_small4_test_promptvariation_fpr")
write_table(shares, "mistral_small4_test_promptvariation_tabelle")
