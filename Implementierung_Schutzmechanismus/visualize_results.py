# Makes the tables and diagrams for the results chapter of the thesis (test split).
# Everything is saved in the folder results_diagramms. The file names start like the
# result files (model, split, approaches), followed by the data set and the content:
#   ..._tabelle_ergebnisse.tex                     all runs with all metrics
#   ..._tabelle_fpr_harmlos.tex                    false positive rate per kind of harmless text
#   ..._<data set>_recall_gesamt                   recall of every run
#   ..._eigen_recall_pro_transformation            own data set, recall per transformation T00 ... T15
#   ..._bipia_obfuscated_recall_pro_transformation obfuscated BIPIA, recall per transformation
#   ..._bipia_recall_pro_aufgabe                   BIPIA, recall per task (e-mail, table, code)
#   ..._bipia_recall_pro_position                  BIPIA, recall per position of the attack
#   ..._<data set>_recall_vs_fpr                   recall against false positive rate
#   ..._<data set>_konfusionsmatrix                confusion matrix of every run
#   ..._<data set>_fpr_pro_harmless_level          false positive rate per kind of harmless text
#   ..._<data set>_regeln_neuer_ansatz             new approach: which rule found the attack / false alarm
#   ..._tabelle_<data set>_recall_pro_transformation.tex  recall per transformation and latency
# The diagrams are saved as .pdf (for LaTeX) and .png.
# Runs without a results file are skipped, so the script can run at any time.
#
# Requirement: python3 -m pip install matplotlib
# Run:         python3 visualize_results.py

import json
import os

import matplotlib.pyplot as plt

import metrics

RESULT_DIR = "results"
DIAGRAM_DIR = "results_diagramms"

# colors: blue of the HSMW template, yellow of the Energy4u logo, gray.
# The yellow is very light, so every bar gets a dark edge and a value label.
HSMW_BLUE = "#0069b4"
ENERGY4U_YELLOW = "#ffd23f"
GRAY = "#9a9a9a"
EDGE = "#333333"

# all runs on the test split: data set, label, file name (without _results.jsonl), color.
# The new approach is the own approach, so it gets the HSMW blue.
RUNS = [
    ["eigen", "Original (Mistral Small 4)", "mistral_small4_test_original_eigen", ENERGY4U_YELLOW],
    ["eigen", "Original (Mistral Large 4)", "mistral_large4_test_original_eigen", GRAY],
    ["eigen", "Neuer Ansatz (Mistral Small 4)", "mistral_small4_test_new_approach_eigen", HSMW_BLUE],
    ["bipia", "Original (Mistral Small 4)", "mistral_small4_test_original_bipia", ENERGY4U_YELLOW],
    ["bipia", "Original (Mistral Large 4)", "mistral_large4_test_original_bipia", GRAY],
    ["bipia", "Neuer Ansatz (Mistral Small 4)", "mistral_small4_test_new_approach_bipia", HSMW_BLUE],
    ["bipia_obfuscated", "Original (Mistral Small 4)",
     "mistral_small4_test_original_bipia_obfuscated", ENERGY4U_YELLOW],
    ["bipia_obfuscated", "Neuer Ansatz (Mistral Small 4)",
     "mistral_small4_test_new_approach_bipia_obfuscated", HSMW_BLUE],
]

DATA_SETS = ["eigen", "bipia", "bipia_obfuscated"]
DATA_SET_NAMES = {"eigen": "Eigener Datensatz", "bipia": "BIPIA + NotInject",
                  "bipia_obfuscated": "BIPIA, verschleiert"}

# start of every file name: model, split, the compared approaches
PREFIX = "mistral_small4_test_new_approach_vs_original_"


# ---------- reading ----------

# reads a jsonl file (one JSON per line)
def load_jsonl(file_name):
    rows = []
    with open(file_name, encoding="utf-8") as file:
        for line in file:
            if line.strip() != "":
                rows.append(json.loads(line))
    return rows


# reads the results and metrics of every run that exists.
# Every run becomes a dictionary with its settings, results and metrics.
def load_runs():
    runs = []
    for data_set, label, name, color in RUNS:
        results_file = os.path.join(RESULT_DIR, name + "_results.jsonl")
        if not os.path.exists(results_file):
            print("Not found, skipped:", results_file)
            continue
        results = load_jsonl(results_file)
        runs.append({
            "data_set": data_set,
            "label": label,
            "name": name,
            "color": color,
            "results": results,
            "metrics": metrics.compute(results, run=name),
        })
    return runs


# only the runs of one data set
def runs_of(runs, data_set):
    selected = []
    for run in runs:
        if run["data_set"] == data_set:
            selected.append(run)
    return selected


# recall per value of a field (for example "task" or "position"), test split only
def recall_by_field(run, field, values):
    recalls = []
    for value in values:
        k = 0
        n = 0
        for row in run["results"]:
            if row["split"] == "test" and row["label"] == "attack" and row.get(field) == value:
                n = n + 1
                if row["flagged"]:
                    k = k + 1
        recalls.append(metrics.share(k, n))
    return recalls


# ---------- LaTeX tables ----------

# 0.731 -> '73{,}1' (German decimal comma)
def percent_tex(rate):
    return f"{100 * rate:.1f}".replace(".", "{,}")


# rate with confidence interval, the interval small and gray
def share_tex(share):
    return (percent_tex(share["rate"]) + r"\,\% {\scriptsize\color{gray}["
            + percent_tex(share["ci_low"]) + "; " + percent_tex(share["ci_high"]) + "]}")


def number_tex(value):
    return f"{value:.3f}".replace(".", "{,}")


def save_text(text, file_name):
    path = os.path.join(DIAGRAM_DIR, file_name)
    with open(path, "w", encoding="utf-8") as file:
        file.write(text)
    print("Saved as", path)


# the label of a run for LaTeX, the new approach in bold
def label_tex(run):
    label = run["label"].replace("Small 4", "Small~4").replace("Large 4", "Large~4")
    if "Neuer Ansatz" in label:
        label = r"\textbf{" + label + "}"
    return label


# one big table with every run of both data sets
def write_results_table(runs):
    lines = [
        r"\resizebox{\textwidth}{!}{%",
        r"\begin{tabular}{l rrrr rr rr r}",
        r"\toprule",
        r"\textbf{Ansatz} & \textbf{TP} & \textbf{FN} & \textbf{FP} & \textbf{TN} & "
        r"\textbf{Recall} & \textbf{FPR} & \textbf{Precision} & \textbf{F1} & "
        r"\textbf{Latenz (Median)} \\",
    ]
    for data_set in DATA_SETS:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        cm = selected[0]["metrics"]["confusion_matrix"]
        attacks = cm["tp"] + cm["fn"]
        harmless = cm["fp"] + cm["tn"]
        lines.append(r"\midrule")
        lines.append(r"\multicolumn{10}{l}{\textit{" + DATA_SET_NAMES[data_set] + " (Test-Split, "
                     + str(attacks) + " Angriffe, " + str(harmless) + " harmlose Texte)}} \\\\")
        for run in selected:
            m = run["metrics"]
            cm = m["confusion_matrix"]
            lines.append(label_tex(run)
                         + " & " + str(cm["tp"]) + " & " + str(cm["fn"])
                         + " & " + str(cm["fp"]) + " & " + str(cm["tn"])
                         + " & " + share_tex(m["recall"]) + " & " + share_tex(m["fpr"])
                         + " & " + number_tex(m["precision"]) + " & " + number_tex(m["f1"])
                         + " & " + f"{m['latency_ms']['median']:.0f}" + r"\,ms \\")
    lines.append(r"\bottomrule")
    lines.append(r"\end{tabular}}")
    save_text("\n".join(lines) + "\n", PREFIX + "tabelle_ergebnisse.tex")


# false positive rate per kind of harmless text
def write_fpr_table(runs):
    # own data set: normal, hard_negative, transformed
    # BIPIA: normal = BIPIA texts without attack, hard_negative = NotInject
    columns = [["normal", "Normal"], ["hard_negative", "Hard Negative"],
               ["transformed", "Transformiert"]]
    lines = [
        r"\begin{tabular}{l rrr r}",
        r"\toprule",
        r"\textbf{Ansatz} & \textbf{Normal} & \textbf{Hard Negative} & "
        r"\textbf{Transformiert} & \textbf{Gesamt} \\",
    ]
    for data_set in DATA_SETS:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        lines.append(r"\midrule")
        lines.append(r"\multicolumn{5}{l}{\textit{" + DATA_SET_NAMES[data_set] + r"}} \\")
        for run in selected:
            cells = []
            for level, title in columns:
                s = run["metrics"]["fpr_by_level"][level]
                if s["n"] == 0:
                    cells.append("--")
                else:
                    cells.append(f"{s['k']}/{s['n']} ({percent_tex(s['rate'])}\\,\\%)")
            s = run["metrics"]["fpr"]
            cells.append(f"{s['k']}/{s['n']} ({percent_tex(s['rate'])}\\,\\%)")
            lines.append(label_tex(run) + " & " + " & ".join(cells) + r" \\")
    lines.append(r"\bottomrule")
    lines.append(r"\end{tabular}")
    save_text("\n".join(lines) + "\n", PREFIX + "tabelle_fpr_harmlos.tex")


# recall per transformation (one row per transformation, one column per run),
# the last rows: recall over all attacks and the latency (median)
def write_transformation_table(runs):
    for data_set in ["eigen", "bipia_obfuscated"]:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        transformations = list(selected[0]["metrics"]["recall_by_transformation"])
        header = r"\textbf{Transformation}"
        for run in selected:
            header = header + " & " + label_tex(run)
        lines = [
            r"\resizebox{\textwidth}{!}{%",
            r"\begin{tabular}{l" + " r" * len(selected) + "}",
            r"\toprule",
            header + r" \\",
            r"\midrule",
        ]
        for transformation in transformations:
            cells = []
            for run in selected:
                s = run["metrics"]["recall_by_transformation"][transformation]
                cells.append(f"{s['k']}/{s['n']} ({percent_tex(s['rate'])}\\,\\%)")
            lines.append(transformation + " & " + " & ".join(cells) + r" \\")
        lines.append(r"\midrule")
        cells = []
        for run in selected:
            s = run["metrics"]["recall"]
            cells.append(f"{s['k']}/{s['n']} ({percent_tex(s['rate'])}\\,\\%)")
        lines.append(r"\textbf{Recall gesamt} & " + " & ".join(cells) + r" \\")
        cells = []
        for run in selected:
            cells.append(f"{run['metrics']['latency_ms']['median']:.0f}" + r"\,ms")
        lines.append(r"\textbf{Latenz (Median)} & " + " & ".join(cells) + r" \\")
        lines.append(r"\bottomrule")
        lines.append(r"\end{tabular}}")
        save_text("\n".join(lines) + "\n",
                  PREFIX + "tabelle_" + data_set + "_recall_pro_transformation.tex")


# ---------- diagrams ----------

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


def save_diagram(figure, name):
    for ending in [".pdf", ".png"]:
        path = os.path.join(DIAGRAM_DIR, name + ending)
        figure.savefig(path, dpi=200, bbox_inches="tight")
        print("Saved as", path)
    plt.close(figure)


# the value above a bar with one decimal and a German decimal comma,
# without ",0": 82.5 -> "82,5", 100.0 -> "100"
def value_label(value):
    text = f"{value:.1f}".replace(".", ",")
    if text.endswith(",0"):
        text = text[:-2]
    return text


# grouped bars: one group per entry of group_names, one bar per run.
# values[r][g] is the share of run r in group g.
def draw_grouped_bars(runs, group_names, values, x_label, name, value_labels=True, width_cm=16,
                      y_label="Recall (%)", legend_y=-0.22):
    figure, ax = plt.subplots(figsize=(width_cm / 2.54, 7 / 2.54))
    bar_width = 0.8 / len(runs)

    for r in range(len(runs)):
        positions = []
        heights = []
        for g in range(len(group_names)):
            positions.append(g - 0.4 + bar_width / 2 + r * bar_width)
            heights.append(100 * values[r][g]["rate"])
        # a small gap between the bars (width * 0.9)
        bars = ax.bar(positions, heights, bar_width * 0.9, label=runs[r]["label"],
                      color=runs[r]["color"], edgecolor=EDGE, linewidth=0.6)
        # value above the bar. A bar with 0 % cannot be seen, so it always gets a "0".
        for bar, height in zip(bars, heights):
            if value_labels or height == 0:
                ax.text(bar.get_x() + bar.get_width() / 2, height + 1.5,
                        value_label(height), ha="center", va="bottom", fontsize=7, color=EDGE)

    ax.set_xticks(range(len(group_names)))
    ax.set_xticklabels(group_names)
    ax.set_ylim(0, 110)
    ax.set_yticks([0, 20, 40, 60, 80, 100])
    ax.set_ylabel(y_label)
    ax.set_xlabel(x_label)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, legend_y), ncol=2, fontsize=8)
    save_diagram(figure, name)


# recall of every run, one group per data set
def draw_recall_overview(runs):
    for data_set in DATA_SETS:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        values = []
        for run in selected:
            values.append([run["metrics"]["recall"]])
        draw_grouped_bars(selected, [DATA_SET_NAMES[data_set]], values, "",
                          PREFIX + data_set + "_recall_gesamt", width_cm=10)


# recall per transformation: own data set (T00 ... T15) and obfuscated BIPIA
# (T01, T02, T03, T08, T14)
def draw_recall_per_transformation(runs):
    for data_set in ["eigen", "bipia_obfuscated"]:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        transformations = list(selected[0]["metrics"]["recall_by_transformation"])
        values = []
        for run in selected:
            row = []
            for transformation in transformations:
                row.append(run["metrics"]["recall_by_transformation"][transformation])
            values.append(row)
        draw_grouped_bars(selected, transformations, values, "Transformation",
                          PREFIX + data_set + "_recall_pro_transformation",
                          value_labels=(data_set != "eigen"))


# BIPIA: recall per task and per position of the attack
def draw_recall_bipia(runs):
    selected = runs_of(runs, "bipia")
    if len(selected) == 0:
        return

    values = []
    for run in selected:
        values.append(recall_by_field(run, "task", ["email", "table", "code"]))
    draw_grouped_bars(selected, ["E-Mail", "Tabelle", "Code"], values,
                      "Art des externen Inhalts", PREFIX + "bipia_recall_pro_aufgabe")

    values = []
    for run in selected:
        values.append(recall_by_field(run, "position", ["start", "middle", "end"]))
    draw_grouped_bars(selected, ["Anfang", "Mitte", "Ende"], values,
                      "Position des Angriffs im Text", PREFIX + "bipia_recall_pro_position")


# recall against false positive rate, one diagram per data set (top left is best).
# The lines show the 95 % confidence interval.
def draw_recall_vs_fpr(runs):
    for data_set in DATA_SETS:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        figure, ax = plt.subplots(figsize=(10 / 2.54, 8 / 2.54))
        ax.grid(True, axis="both")
        for run in selected:
            recall = run["metrics"]["recall"]
            fpr = run["metrics"]["fpr"]
            ax.errorbar(100 * fpr["rate"], 100 * recall["rate"],
                        xerr=[[100 * (fpr["rate"] - fpr["ci_low"])], [100 * (fpr["ci_high"] - fpr["rate"])]],
                        yerr=[[100 * (recall["rate"] - recall["ci_low"])], [100 * (recall["ci_high"] - recall["rate"])]],
                        fmt="o", markersize=8, color=run["color"], markeredgecolor=EDGE,
                        ecolor="#555555", elinewidth=0.8, capsize=2, label=run["label"])
        ax.set_xlim(-1, 30)
        ax.set_ylim(0, 100)
        ax.set_xlabel("Falsch-Positiv-Rate (%)")
        ax.set_ylabel("Recall (%)")
        ax.set_title(DATA_SET_NAMES[data_set], fontsize=9)
        ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.2), ncol=1, fontsize=8)
        save_diagram(figure, PREFIX + data_set + "_recall_vs_fpr")


# confusion matrix of every run, one diagram per data set with one matrix per run
def draw_confusion_matrices(runs):
    for data_set in DATA_SETS:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        figure, axes = plt.subplots(1, len(selected), figsize=(5.5 * len(selected) / 2.54, 6 / 2.54))
        if len(selected) == 1:
            axes = [axes]
        for ax, run in zip(axes, selected):
            cm = run["metrics"]["confusion_matrix"]
            # rows: actual (attack, harmless), columns: prediction (attack, harmless)
            cells = [[cm["tp"], cm["fn"]], [cm["fp"], cm["tn"]]]
            row_sums = [cm["tp"] + cm["fn"], cm["fp"] + cm["tn"]]
            # the color shows the share of the row, so both rows can be compared
            shares = [[cells[i][j] / row_sums[i] if row_sums[i] > 0 else 0 for j in range(2)]
                      for i in range(2)]
            ax.imshow(shares, cmap="Blues", vmin=0, vmax=1)
            ax.grid(False)
            for i in range(2):
                for j in range(2):
                    color = "white" if shares[i][j] > 0.6 else EDGE
                    ax.text(j, i, str(cells[i][j]), ha="center", va="center", fontsize=10, color=color)
            ax.set_xticks([0, 1])
            ax.set_xticklabels(["Angriff", "harmlos"])
            ax.set_yticks([0, 1])
            ax.set_yticklabels(["Angriff", "harmlos"])
            ax.set_xlabel("Vorhersage")
            ax.set_title(run["label"].replace(" (", "\n("), fontsize=8)
            for side in ["top", "right", "bottom", "left"]:
                ax.spines[side].set_visible(False)
        axes[0].set_ylabel("Tatsächlich")
        figure.tight_layout()
        save_diagram(figure, PREFIX + data_set + "_konfusionsmatrix")


# false positive rate per kind of harmless text, one diagram per data set
def draw_fpr_per_level(runs):
    level_names = {
        "eigen": [["normal", "Normal"], ["hard_negative", "Hard Negative"],
                  ["transformed", "Transformiert"]],
        "bipia": [["normal", "BIPIA ohne Angriff"], ["hard_negative", "NotInject"]],
    }
    for data_set in ["eigen", "bipia"]:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        levels = []
        for level, title in level_names[data_set]:
            if selected[0]["metrics"]["fpr_by_level"][level]["n"] > 0:
                levels.append([level, title])
        values = []
        for run in selected:
            row = []
            for level, title in levels:
                row.append(run["metrics"]["fpr_by_level"][level])
            values.append(row)
        group_names = []
        for level, title in levels:
            group_names.append(title + "\n(n = " + str(selected[0]["metrics"]["fpr_by_level"][level]["n"]) + ")")
        draw_grouped_bars(selected, group_names, values, "Art des harmlosen Textes",
                          PREFIX + data_set + "_fpr_pro_harmless_level", width_cm=12,
                          y_label="Falsch-Positiv-Rate (%)", legend_y=-0.32)


# new approach: which of the two rules found the attack or caused the false alarm.
# The reason of a row is for example "G+C1_VN" or "C1_V0+C2_VN".
#   user message:     rule 1 = form check G (guard),  rule 2 = guiding questions C1
#   external content: rule 1 = structure check C2,    rule 2 = guiding questions C1
def draw_rules_new_approach(runs):
    for run in runs:
        if "Neuer Ansatz" not in run["label"]:
            continue
        names = ["Formprüfung (G) /\nStrukturprüfung (C2)", "Leitfragen (C1)", "beide Regeln"]
        counts = {"attack": [0, 0, 0], "harmless": [0, 0, 0]}
        for row in run["results"]:
            if row["split"] != "test" or not row["flagged"]:
                continue
            checks = row["reason"].split("+")
            rule_1 = False
            rule_2 = False
            for check in checks:
                if check == "G" or check.startswith("C2_"):
                    rule_1 = True
                if check.startswith("C1_"):
                    rule_2 = True
            if rule_1 and rule_2:
                counts[row["label"]][2] += 1
            elif rule_1:
                counts[row["label"]][0] += 1
            elif rule_2:
                counts[row["label"]][1] += 1

        figure, ax = plt.subplots(figsize=(12 / 2.54, 7 / 2.54))
        bar_width = 0.4
        bars_attack = ax.bar([g - bar_width / 2 for g in range(3)], counts["attack"], bar_width * 0.9,
                             label="erkannte Angriffe (TP)", color=HSMW_BLUE, edgecolor=EDGE, linewidth=0.6)
        bars_harmless = ax.bar([g + bar_width / 2 for g in range(3)], counts["harmless"], bar_width * 0.9,
                               label="Fehlalarme (FP)", color=GRAY, edgecolor=EDGE, linewidth=0.6)
        highest = max(counts["attack"] + counts["harmless"] + [1])
        for bars in [bars_attack, bars_harmless]:
            for bar in bars:
                ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + highest * 0.015,
                        str(int(bar.get_height())), ha="center", va="bottom", fontsize=7, color=EDGE)
        ax.set_xticks(range(3))
        ax.set_xticklabels(names)
        ax.set_ylim(0, highest * 1.15)
        ax.set_ylabel("Anzahl")
        ax.set_xlabel("ausgelöste Regel")
        ax.set_title(DATA_SET_NAMES[run["data_set"]], fontsize=9)
        ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.32), ncol=2, fontsize=8)
        save_diagram(figure, PREFIX + run["data_set"] + "_regeln_neuer_ansatz")


# ---------- start ----------

os.makedirs(DIAGRAM_DIR, exist_ok=True)
thesis_style()
all_runs = load_runs()

write_results_table(all_runs)
write_fpr_table(all_runs)
write_transformation_table(all_runs)
draw_recall_overview(all_runs)
draw_recall_per_transformation(all_runs)
draw_recall_bipia(all_runs)
draw_recall_vs_fpr(all_runs)
draw_confusion_matrices(all_runs)
draw_fpr_per_level(all_runs)
draw_rules_new_approach(all_runs)
