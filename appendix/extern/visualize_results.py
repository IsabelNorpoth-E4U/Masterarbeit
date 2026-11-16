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

# start of every file name: model, split, the compared approaches
PREFIX = "mistral_small4_test_new_approach_vs_original_"

# colors: blue of the HSMW template, yellow of the Energy4u logo, gray.
# The yellow is very light, so every bar gets a dark edge and a value label.
BLUE = "#0069b4"
YELLOW = "#ffd23f"
GRAY = "#9a9a9a"
EDGE = "#333333"

# all runs on the test split: data set, label, file name (without _results.jsonl), color.
# The new approach is the own approach, so it gets the HSMW blue.
RUNS = [
    ["eigen", "Original (Mistral Small 4)", "mistral_small4_test_original_eigen", YELLOW],
    ["eigen", "Original (Mistral Large 4)", "mistral_large4_test_original_eigen", GRAY],
    ["eigen", "Neuer Ansatz (Mistral Small 4)", "mistral_small4_test_new_approach_eigen", BLUE],
    ["bipia", "Original (Mistral Small 4)", "mistral_small4_test_original_bipia", YELLOW],
    ["bipia", "Original (Mistral Large 4)", "mistral_large4_test_original_bipia", GRAY],
    ["bipia", "Neuer Ansatz (Mistral Small 4)", "mistral_small4_test_new_approach_bipia", BLUE],
    ["bipia_obfuscated", "Original (Mistral Small 4)", "mistral_small4_test_original_bipia_obfuscated", YELLOW],
    ["bipia_obfuscated", "Neuer Ansatz (Mistral Small 4)", "mistral_small4_test_new_approach_bipia_obfuscated", BLUE],
]

DATA_SETS = ["eigen", "bipia", "bipia_obfuscated"]
DATA_SET_NAMES = {
    "eigen": "Eigener Datensatz",
    "bipia": "BIPIA + NotInject",
    "bipia_obfuscated": "BIPIA, verschleiert",
}

# simple look of the diagrams: no frame on top and right, light grid behind the bars
plt.rcParams["font.size"] = 9
plt.rcParams["axes.spines.top"] = False
plt.rcParams["axes.spines.right"] = False
plt.rcParams["axes.axisbelow"] = True
plt.rcParams["axes.grid"] = True
plt.rcParams["axes.grid.axis"] = "y"
plt.rcParams["grid.color"] = "#dddddd"
plt.rcParams["legend.frameon"] = False
plt.rcParams["pdf.fonttype"] = 42  # text stays text in the pdf


# ---------- helper functions ----------

# reads the results of every run that exists and computes the metrics
def load_runs():
    runs = []
    for data_set, label, name, color in RUNS:
        file_name = os.path.join(RESULT_DIR, name + "_results.jsonl")
        if not os.path.exists(file_name):
            print("Not found, skipped:", file_name)
            continue
        results = []
        with open(file_name, encoding="utf-8") as file:
            for line in file:
                if line.strip() != "":
                    results.append(json.loads(line))
        run = {}
        run["data_set"] = data_set
        run["label"] = label
        run["color"] = color
        run["results"] = results
        run["metrics"] = metrics.compute(results, run=name)
        runs.append(run)
    return runs


# only the runs of one data set
def runs_of(runs, data_set):
    selected = []
    for run in runs:
        if run["data_set"] == data_set:
            selected.append(run)
    return selected


# 0.731 -> '73{,}1' (German decimal comma in LaTeX)
def percent_tex(rate):
    return f"{100 * rate:.1f}".replace(".", "{,}")


# share -> '19/26 (73{,}1\,\%)'
def fraction_tex(s):
    return str(s["k"]) + "/" + str(s["n"]) + " (" + percent_tex(s["rate"]) + r"\,\%)"


# the label of a run for LaTeX, the new approach in bold
def label_tex(run):
    label = run["label"].replace("Small 4", "Small~4").replace("Large 4", "Large~4")
    if "Neuer Ansatz" in label:
        label = r"\textbf{" + label + "}"
    return label


def save_text(lines, file_name):
    path = os.path.join(DIAGRAM_DIR, file_name)
    with open(path, "w", encoding="utf-8") as file:
        file.write("\n".join(lines) + "\n")
    print("Saved as", path)


def save_diagram(figure, name):
    for ending in [".pdf", ".png"]:
        path = os.path.join(DIAGRAM_DIR, name + ending)
        figure.savefig(path, dpi=200, bbox_inches="tight")
        print("Saved as", path)
    plt.close(figure)


# the value above a bar: 82.5 -> "82,5", 100.0 -> "100"
def value_label(value):
    text = f"{value:.1f}".replace(".", ",")
    if text.endswith(",0"):
        text = text[:-2]
    return text


# recall per value of a field (for example "task" or "position")
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


# grouped bars: one group per entry of group_names, one bar per run.
# values[r][g] is the share of run r in group g.
def draw_grouped_bars(runs, group_names, values, x_label, name, value_labels=True,
                      width_cm=16, y_label="Recall (%)", legend_y=-0.22):
    figure, ax = plt.subplots(figsize=(width_cm / 2.54, 7 / 2.54))
    bar_width = 0.8 / len(runs)

    for r in range(len(runs)):
        positions = []
        heights = []
        for g in range(len(group_names)):
            positions.append(g - 0.4 + bar_width / 2 + r * bar_width)
            heights.append(100 * values[r][g]["rate"])
        # a small gap between the bars (width * 0.9)
        ax.bar(positions, heights, bar_width * 0.9, label=runs[r]["label"],
               color=runs[r]["color"], edgecolor=EDGE, linewidth=0.6)
        # value above the bar. A bar with 0 % cannot be seen, so it always gets a "0".
        for g in range(len(group_names)):
            if value_labels or heights[g] == 0:
                ax.text(positions[g], heights[g] + 1.5, value_label(heights[g]),
                        ha="center", va="bottom", fontsize=7, color=EDGE)

    ax.set_xticks(range(len(group_names)))
    ax.set_xticklabels(group_names)
    ax.set_ylim(0, 110)
    ax.set_yticks([0, 20, 40, 60, 80, 100])
    ax.set_ylabel(y_label)
    ax.set_xlabel(x_label)
    ax.legend(loc="upper center", bbox_to_anchor=(0.5, legend_y), ncol=2, fontsize=8)
    save_diagram(figure, name)


# ---------- LaTeX tables ----------

# one big table with every run of all data sets
def write_results_table(runs):
    lines = []
    lines.append(r"\begin{tabular}{l rrrr rr r}")
    lines.append(r"\toprule")
    lines.append(r"\textbf{Ansatz} & \textbf{TP} & \textbf{FN} & \textbf{FP} & \textbf{TN} & "
                 r"\textbf{Recall} & \textbf{FPR} & \textbf{Latenz (Median)} \\")
    for data_set in DATA_SETS:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        cm = selected[0]["metrics"]["confusion_matrix"]
        attacks = cm["tp"] + cm["fn"]
        harmless = cm["fp"] + cm["tn"]
        lines.append(r"\midrule")
        lines.append(r"\multicolumn{8}{l}{\textit{" + DATA_SET_NAMES[data_set] + " (Test-Split, "
                     + str(attacks) + " Angriffe, " + str(harmless) + r" harmlose Texte)}} \\")
        for run in selected:
            m = run["metrics"]
            cm = m["confusion_matrix"]
            recall = percent_tex(m["recall"]["rate"]) + r"\,\%"
            fpr = percent_tex(m["fpr"]["rate"]) + r"\,\%"
            latency = f"{m['latency_ms']['median']:.0f}" + r"\,ms"
            lines.append(label_tex(run) + " & " + str(cm["tp"]) + " & " + str(cm["fn"])
                         + " & " + str(cm["fp"]) + " & " + str(cm["tn"])
                         + " & " + recall + " & " + fpr + " & " + latency + r" \\")
    lines.append(r"\bottomrule")
    lines.append(r"\end{tabular}")
    save_text(lines, PREFIX + "tabelle_ergebnisse.tex")


# false positive rate per kind of harmless text
# own data set: normal, hard_negative, transformed
# BIPIA: normal = BIPIA texts without attack, hard_negative = NotInject
def write_fpr_table(runs):
    lines = []
    lines.append(r"\begin{tabular}{l rrr r}")
    lines.append(r"\toprule")
    lines.append(r"\textbf{Ansatz} & \textbf{Normal} & \textbf{Hard Negative} & "
                 r"\textbf{Transformiert} & \textbf{Gesamt} \\")
    for data_set in DATA_SETS:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        lines.append(r"\midrule")
        lines.append(r"\multicolumn{5}{l}{\textit{" + DATA_SET_NAMES[data_set] + r"}} \\")
        for run in selected:
            line = label_tex(run)
            for level in ["normal", "hard_negative", "transformed"]:
                s = run["metrics"]["fpr_by_level"][level]
                if s["n"] == 0:
                    line = line + " & --"
                else:
                    line = line + " & " + fraction_tex(s)
            line = line + " & " + fraction_tex(run["metrics"]["fpr"])
            lines.append(line + r" \\")
    lines.append(r"\bottomrule")
    lines.append(r"\end{tabular}")
    save_text(lines, PREFIX + "tabelle_fpr_harmlos.tex")


# recall per transformation (one row per transformation, one column per run),
# the last rows: recall over all attacks and the latency (median)
def write_transformation_table(runs):
    for data_set in ["eigen", "bipia_obfuscated"]:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        header = r"\textbf{Transformation}"
        for run in selected:
            header = header + " & " + label_tex(run)
        lines = []
        lines.append(r"\begin{tabular}{l" + " r" * len(selected) + "}")
        lines.append(r"\toprule")
        lines.append(header + r" \\")
        lines.append(r"\midrule")
        for transformation in selected[0]["metrics"]["recall_by_transformation"]:
            line = transformation
            for run in selected:
                line = line + " & " + fraction_tex(run["metrics"]["recall_by_transformation"][transformation])
            lines.append(line + r" \\")
        lines.append(r"\midrule")
        line = r"\textbf{Recall gesamt}"
        for run in selected:
            line = line + " & " + fraction_tex(run["metrics"]["recall"])
        lines.append(line + r" \\")
        line = r"\textbf{Latenz (Median)}"
        for run in selected:
            line = line + " & " + f"{run['metrics']['latency_ms']['median']:.0f}" + r"\,ms"
        lines.append(line + r" \\")
        lines.append(r"\bottomrule")
        lines.append(r"\end{tabular}")
        save_text(lines, PREFIX + "tabelle_" + data_set + "_recall_pro_transformation.tex")


# ---------- diagrams ----------

# recall of every run, one diagram per data set
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
        # the own data set has many bars, so no value labels there
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
            x = 100 * fpr["rate"]
            y = 100 * recall["rate"]
            x_low = x - 100 * fpr["ci_low"]
            x_high = 100 * fpr["ci_high"] - x
            y_low = y - 100 * recall["ci_low"]
            y_high = 100 * recall["ci_high"] - y
            ax.errorbar(x, y, xerr=[[x_low], [x_high]], yerr=[[y_low], [y_high]],
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
        for i in range(len(selected)):
            ax = axes[i]
            run = selected[i]
            cm = run["metrics"]["confusion_matrix"]
            # rows: actual (attack, harmless), columns: prediction (attack, harmless)
            cells = [[cm["tp"], cm["fn"]], [cm["fp"], cm["tn"]]]
            # the color shows the share of the row, so both rows can be compared
            shares = [[0, 0], [0, 0]]
            for row in range(2):
                row_sum = cells[row][0] + cells[row][1]
                for col in range(2):
                    if row_sum > 0:
                        shares[row][col] = cells[row][col] / row_sum
            ax.imshow(shares, cmap="Blues", vmin=0, vmax=1)
            ax.grid(False)
            for row in range(2):
                for col in range(2):
                    color = EDGE
                    if shares[row][col] > 0.6:
                        color = "white"
                    ax.text(col, row, str(cells[row][col]), ha="center", va="center",
                            fontsize=10, color=color)
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
        "eigen": [["normal", "Normal"], ["hard_negative", "Hard Negative"], ["transformed", "Transformiert"]],
        "bipia": [["normal", "BIPIA ohne Angriff"], ["hard_negative", "NotInject"]],
    }
    for data_set in ["eigen", "bipia"]:
        selected = runs_of(runs, data_set)
        if len(selected) == 0:
            continue
        # only the kinds of harmless text that exist in the data set
        levels = []
        group_names = []
        for level, title in level_names[data_set]:
            n = selected[0]["metrics"]["fpr_by_level"][level]["n"]
            if n > 0:
                levels.append(level)
                group_names.append(title + "\n(n = " + str(n) + ")")
        values = []
        for run in selected:
            row = []
            for level in levels:
                row.append(run["metrics"]["fpr_by_level"][level])
            values.append(row)
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
        # counts[...][0] = only rule 1, [1] = only rule 2, [2] = both rules
        counts = {"attack": [0, 0, 0], "harmless": [0, 0, 0]}
        for row in run["results"]:
            if row["split"] != "test" or not row["flagged"]:
                continue
            rule_1 = False
            rule_2 = False
            for check in row["reason"].split("+"):
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

        highest = max(counts["attack"] + counts["harmless"] + [1])
        figure, ax = plt.subplots(figsize=(12 / 2.54, 7 / 2.54))
        bars_attack = ax.bar([-0.2, 0.8, 1.8], counts["attack"], 0.4 * 0.9, label="erkannte Angriffe (TP)",
                             color=BLUE, edgecolor=EDGE, linewidth=0.6)
        bars_harmless = ax.bar([0.2, 1.2, 2.2], counts["harmless"], 0.4 * 0.9, label="Fehlalarme (FP)",
                               color=GRAY, edgecolor=EDGE, linewidth=0.6)
        # the number above every bar
        for bar in list(bars_attack) + list(bars_harmless):
            x = bar.get_x() + bar.get_width() / 2
            height = bar.get_height()
            ax.text(x, height + highest * 0.015, str(int(height)),
                    ha="center", va="bottom", fontsize=7, color=EDGE)
        ax.set_xticks(range(3))
        ax.set_xticklabels(["Formprüfung (G) /\nStrukturprüfung (C2)", "Leitfragen (C1)", "beide Regeln"])
        ax.set_ylim(0, highest * 1.15)
        ax.set_ylabel("Anzahl")
        ax.set_xlabel("ausgelöste Regel")
        ax.set_title(DATA_SET_NAMES[run["data_set"]], fontsize=9)
        ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.32), ncol=2, fontsize=8)
        save_diagram(figure, PREFIX + run["data_set"] + "_regeln_neuer_ansatz")


# ---------- start ----------

os.makedirs(DIAGRAM_DIR, exist_ok=True)
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
