# Shows the results of the Mistral guard runs as tables
# and saves every picture in the results folder.
# The diagrams and LaTeX tables for the thesis are saved in the folder results_diagramms.
#
# Requirement: python3 -m pip install matplotlib
# Run:         python3 visualize_results.py

import json
import os

import matplotlib.pyplot as plt

# Folder in which this script is located
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RESULT_DIR = os.path.join(BASE_DIR, "results")
DIAGRAM_DIR = os.path.join(BASE_DIR, "results_diagramms")

# colors for the thesis: blue of the HSMW template, yellow of the Energy4u logo
HSMW_BLUE = "#0069b4"
ENERGY4U_YELLOW = "#ffd23f"
GRAY = "#9a9a9a"

# runs in the thesis (test split): label, metrics file, color.
# The hybrid is the own approach, so it gets the HSMW blue.
THESIS_RUNS = [
    ["Mistral Small 4", "mistral_small4_metrics.json", ENERGY4U_YELLOW],
    ["Mistral Large 4", "mistral_large4_metrics.json", GRAY],
    ["Mistral Small 4 (neuer Ansatz)", "mistral_small4_hybrid2_metrics.json", HSMW_BLUE],
]

# All runs that should be shown: name, model, results file, picture file.
# Original approach = main_original_mistral.py, Hybrid = main_hybrid_mistral.py,
# Large 4 = main_original_mistral_large4.py, BIPIA = main_bipia_*_mistral.py
# (external test set, only test split). The older runs are in the folder archiv.
RUNS = [
    ["Original approach", "Mistral Small 4", "mistral_small4_results.jsonl", "mistral_small4_tables.png"],
    ["Hybrid", "Mistral Small 4", "mistral_small4_hybrid2_results.jsonl", "mistral_small4_hybrid2_tables.png"],
    ["Large 4", "Mistral Large 4", "mistral_large4_results.jsonl", "mistral_large4_tables.png"],
    ["BIPIA original approach", "Mistral Small 4", "bipia_mistral_small4_results.jsonl", "bipia_mistral_small4_tables.png"],
    ["BIPIA hybrid", "Mistral Small 4", "bipia_mistral_small4_hybrid2_results.jsonl", "bipia_mistral_small4_hybrid2_tables.png"],
    # version 2: prompt for external content
    ["BIPIA prompt 2 original approach", "Mistral Small 4", "bipia_prompt2_mistral_small4_results.jsonl", "bipia_prompt2_mistral_small4_tables.png"],
    ["BIPIA prompt 2 hybrid", "Mistral Small 4", "bipia_prompt2_mistral_small4_hybrid2_results.jsonl", "bipia_prompt2_mistral_small4_hybrid2_tables.png"],
]
# runs that are compared with each other (dev and test split): run names, picture file
COMPARISONS = [
    [["Original approach", "Hybrid"], "mistral_small4_comparison.png"],
    [["Original approach", "Large 4"], "mistral_small4_vs_large4_comparison.png"],
    [["BIPIA original approach", "BIPIA hybrid"], "bipia_mistral_small4_comparison.png"],
    [["BIPIA prompt 2 original approach", "BIPIA prompt 2 hybrid"], "bipia_prompt2_mistral_small4_comparison.png"],
]

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


# ---------- Diagrams and tables for the thesis ----------

# percent with German decimal comma for LaTeX, 0.731 -> '73{,}1'
def percent_tex(rate):
    return f"{100 * rate:.1f}".replace(".", "{,}")


# rate with confidence interval for LaTeX, small and gray
def share_tex(share):
    return (percent_tex(share["rate"]) + r"\,\% {\scriptsize\color{gray}["
            + percent_tex(share["ci_low"]) + "; " + percent_tex(share["ci_high"]) + "]}")


# distance from the rate to both ends of the confidence interval, in percent
def error_bar(share):
    return [100 * (share["rate"] - share["ci_low"]), 100 * (share["ci_high"] - share["rate"])]


def save_diagram(figure, name):
    for ending in [".pdf", ".png"]:
        out_file = os.path.join(DIAGRAM_DIR, name + ending)
        figure.savefig(out_file, dpi=200, bbox_inches="tight")
        print("Saved as", out_file)


# simple look: no frame on top and right, light grid behind the bars
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


# grouped bars: recall per transformation for every run
def draw_recall_per_transformation(runs):
    transformations = list(runs[0][1]["recall_by_transformation"])
    width = 0.8 / len(runs)

    figure, ax = plt.subplots(figsize=(6.3, 3.0))

    for r in range(len(runs)):
        label, metrics, color = runs[r]
        positions = []
        heights = []
        for i in range(len(transformations)):
            share = metrics["recall_by_transformation"][transformations[i]]
            positions.append(i - 0.4 + width / 2 + r * width)
            heights.append(100 * share["rate"])
        ax.bar(positions, heights, width, label=label, color=color,
               edgecolor="#333333", linewidth=0.4)

    ax.set_xticks(range(len(transformations)))
    ax.set_xticklabels(transformations, fontsize=8)
    ax.set_ylim(0, 105)
    ax.set_ylabel("Recall (%)")
    ax.set_xlabel("Transformation")

    ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.2), ncol=3, fontsize=8)

    save_diagram(figure, "recall_pro_transformation")


# recall against false positive rate, one point per run (top left is best)
def draw_recall_vs_fpr(runs):
    figure, ax = plt.subplots(figsize=(4.2, 3.2))
    ax.grid(True, axis="both")

    for label, metrics, color in runs:
        recall = metrics["recall"]
        fpr = metrics["fpr"]
        ax.errorbar(100 * fpr["rate"], 100 * recall["rate"],
                    xerr=[[error_bar(fpr)[0]], [error_bar(fpr)[1]]],
                    yerr=[[error_bar(recall)[0]], [error_bar(recall)[1]]],
                    fmt="o", markersize=8, color=color, markeredgecolor="#333333",
                    ecolor="#555555", elinewidth=0.8, capsize=2, label=label)

    ax.set_xlim(-1, 20)
    ax.set_ylim(0, 100)
    ax.set_xlabel("Falsch-Positiv-Rate (%)")
    ax.set_ylabel("Recall (%)")
    ax.legend(loc="lower right", fontsize=8)

    save_diagram(figure, "recall_vs_fpr")


def save_table(text, name):
    out_file = os.path.join(DIAGRAM_DIR, name + ".tex")
    with open(out_file, "w", encoding="utf-8") as file:
        file.write(text)
    print("Saved as", out_file)


# LaTeX table with all runs. The own approach (hybrid) has a light blue row.
def write_overview_table(runs):
    lines = [
        r"\begin{tabular}{l rr rr}",
        r"\toprule",
        r" & \multicolumn{2}{c}{\textbf{Erkennung}} & \multicolumn{2}{c}{\textbf{Gesamt}} \\",
        r"\cmidrule(lr){2-3} \cmidrule(lr){4-5}",
        r"\textbf{Ansatz} & \textbf{Recall} & \textbf{FPR} & \textbf{F1} & \textbf{Latenz (Median)} \\",
        r"\midrule",
    ]
    for label, metrics, color in runs:
        row = (label.replace("Small 4", r"Small~4").replace("Large 4", r"Large~4")
               + " & " + share_tex(metrics["recall"])
               + " & " + share_tex(metrics["fpr"])
               + " & " + f"{metrics['f1']:.3f}".replace(".", "{,}")
               + " & " + f"{metrics['latency_ms']['median']:.0f}" + r"\,ms \\")
        if color == HSMW_BLUE:
            row = r"\rowcolor{hsmw!10}" + "\n" + row
        lines.append(row)
    lines.append(r"\bottomrule")
    lines.append(r"\end{tabular}")
    save_table("\n".join(lines) + "\n", "tabelle_gesamtvergleich")


# LaTeX table: false positive rate per kind of harmless request
def write_fpr_table(runs):
    levels = [["normal", "Normal"], ["hard_negative", "Hard Negative"],
              ["transformed", "Transformiert"]]
    lines = [
        r"\begin{tabular}{l" + " r" * len(runs) + "}",
        r"\toprule",
    ]
    # two header lines: model and "(neuer Ansatz)", which is empty for the other runs
    models = []
    approaches = []
    for label, metrics, color in runs:
        model = label
        approach = ""
        if " (" in label:
            model, approach = label.split(" (")
            approach = "(" + approach
        models.append(r"\textbf{" + model.replace(" 4", "~4") + "}")
        approaches.append(r"\textbf{" + approach + "}")
    lines.append(r"\textbf{Art der harmlosen Anfrage} & " + " & ".join(models) + r" \\")
    lines.append(r" & " + " & ".join(approaches) + r" \\")
    lines.append(r"\midrule")
    for level, name in levels:
        cells = []
        for label, metrics, color in runs:
            share = metrics["fpr_by_level"][level]
            cells.append(f"{share['k']}/{share['n']} ({percent_tex(share['rate'])}\\,\\%)")
        lines.append(name + " & " + " & ".join(cells) + r" \\")
    lines.append(r"\midrule")
    cells = []
    for label, metrics, color in runs:
        share = metrics["fpr"]
        cells.append(r"\textbf{" + f"{share['k']}/{share['n']} ({percent_tex(share['rate'])}\\,\\%)" + "}")
    lines.append(r"\textbf{Gesamt} & " + " & ".join(cells) + r" \\")
    lines.append(r"\bottomrule")
    lines.append(r"\end{tabular}")
    save_table("\n".join(lines) + "\n", "tabelle_fpr_harmlos")


def create_thesis_figures():
    runs = []
    for label, metrics_file, color in THESIS_RUNS:
        path = os.path.join(RESULT_DIR, metrics_file)
        if not os.path.exists(path):
            print("Not found, skipped:", path)
            continue
        with open(path, encoding="utf-8") as file:
            runs.append([label, json.load(file), color])
    if len(runs) == 0:
        return

    os.makedirs(DIAGRAM_DIR, exist_ok=True)
    thesis_style()
    draw_recall_per_transformation(runs)
    draw_recall_vs_fpr(runs)
    write_overview_table(runs)
    write_fpr_table(runs)


# ---------- Main program ----------

# results of every run, for the comparisons at the end
all_rows = {}

for run in RUNS:
    name = run[0]
    model_name = run[1]
    results_file = os.path.join(RESULT_DIR, run[2])
    out_file = os.path.join(RESULT_DIR, run[3])

    # skip runs that do not exist yet
    if not os.path.exists(results_file):
        print("Not found, skipped:", results_file)
        continue

    rows = read_results(results_file)

    tables = {"Total": {"all": rows}, "Per split": {}, "Per harmless_level": {}}
    for row in rows:
        add_to_group(tables["Per split"], "split = " + str(row["split"]), row)
        add_to_group(tables["Per harmless_level"], "harmless_level = " + str(row["harmless_level"]), row)
        # only the BIPIA runs have a task (email, table, code, prompt = NotInject)
        if "task" in row:
            if "Per task" not in tables:
                tables["Per task"] = {}
            add_to_group(tables["Per task"], "task = " + str(row["task"]), row)

    draw_figure(tables, "Prompt injection detection with " + model_name + " – " + name, out_file)

    # row name in the comparison tables, with model so runs of both models can be told apart
    all_rows[name] = [model_name + " – " + name, rows]

# one picture per comparison with the runs next to each other (dev and test split)
for compare in COMPARISONS:
    names = compare[0]
    comparison = {"Dev split": {}, "Test split": {}}
    for name in names:
        if name not in all_rows:
            continue
        label = all_rows[name][0]
        for row in all_rows[name][1]:
            if row["split"] == "dev":
                add_to_group(comparison["Dev split"], label, row)
            if row["split"] == "test":
                add_to_group(comparison["Test split"], label, row)

    # the BIPIA runs have no dev split, an empty table cannot be drawn
    if len(comparison["Dev split"]) == 0:
        del comparison["Dev split"]

    if len(comparison["Test split"]) > 1:
        labels = []
        for name in names:
            labels.append(all_rows[name][0])
        draw_figure(comparison, "Comparison: " + " vs. ".join(labels),
                    os.path.join(RESULT_DIR, compare[1]))

# diagrams and tables for the results chapter of the thesis
create_thesis_figures()

plt.show()