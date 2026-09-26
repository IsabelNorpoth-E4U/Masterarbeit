"""Ergebnisse der Prompt-Injection-Erkennung als Tabellen darstellen.

Liest results/qwen35_results.jsonl, berechnet Kennzahlen (gesamt, je Split,
je harmless_level) und zeigt sie mit matplotlib als Tabellen an. Das Bild wird
zusaetzlich als results/qwen35_tabellen.png gespeichert.

Voraussetzung: python3 -m pip install matplotlib
Aufruf: python3 plot_results.py
"""

import json
import os
from collections import Counter, defaultdict

import matplotlib.pyplot as plt

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RESULT_DIR = os.path.join(BASE_DIR, "results")
RESULTS_FILE = os.path.join(RESULT_DIR, "qwen35_results.jsonl")
OUT_FILE = os.path.join(RESULT_DIR, "qwen35_tabellen.png")

# Label-Werte, die als "Angriff" gelten. Bei anderer Kodierung hier ergaenzen.
POSITIVE_LABELS = {"1", "true", "injection", "attack", "malicious", "ja", "yes"}

COLUMNS = ["n", "TP", "FP", "FN", "TN", "Accuracy", "Precision",
           "Recall", "F1", "FPR", "Latenz Ø (ms)"]


def is_attack(label) -> bool:
    return str(label).strip().lower() in POSITIVE_LABELS


def fmt(x) -> str:
    return "–" if x is None else f"{x:.3f}"


def kennzahlen(rows: list[dict]) -> list[str]:
    tp = sum(r["flagged"] and is_attack(r["label"]) for r in rows)
    fp = sum(r["flagged"] and not is_attack(r["label"]) for r in rows)
    fn = sum(not r["flagged"] and is_attack(r["label"]) for r in rows)
    tn = sum(not r["flagged"] and not is_attack(r["label"]) for r in rows)
    n = len(rows)

    precision = tp / (tp + fp) if tp + fp else None
    recall = tp / (tp + fn) if tp + fn else None
    if precision is None or recall is None:
        f1 = None
    else:
        f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    accuracy = (tp + tn) / n if n else None
    fpr = fp / (fp + tn) if fp + tn else None
    latenz = sum(r["latency_ms"] for r in rows) / n if n else 0

    return [str(n), str(tp), str(fp), str(fn), str(tn), fmt(accuracy),
            fmt(precision), fmt(recall), fmt(f1), fmt(fpr), f"{latenz:.0f}"]


def gruppiert(rows: list[dict], key: str) -> tuple[list[str], list[list[str]]]:
    gruppen = defaultdict(list)
    for r in rows:
        gruppen[r.get(key)].append(r)
    namen = sorted(gruppen, key=lambda k: (k is None, str(k)))
    return [f"{key} = {k}" for k in namen], [kennzahlen(gruppen[k]) for k in namen]


def zeichne_tabelle(ax, titel: str, zeilen: list[str], daten: list[list[str]]) -> None:
    ax.axis("off")
    ax.set_title(titel, fontsize=12, fontweight="bold", loc="left")
    tabelle = ax.table(cellText=daten, rowLabels=zeilen, colLabels=COLUMNS,
                       loc="upper center", cellLoc="center")
    tabelle.auto_set_font_size(False)
    tabelle.set_fontsize(9)
    tabelle.scale(1, 1.4)
    for (zeile, spalte), zelle in tabelle.get_celld().items():
        if zeile == 0 or spalte == -1:
            zelle.set_text_props(fontweight="bold")
            zelle.set_facecolor("#e6e6e6")
        elif zeile % 2 == 0:
            zelle.set_facecolor("#f7f7f7")


def main() -> None:
    with open(RESULTS_FILE, encoding="utf-8") as fh:
        rows = [json.loads(line) for line in fh if line.strip()]
    if not rows:
        print("Keine Ergebnisse gefunden.")
        return

    labels = Counter(str(r["label"]) for r in rows)
    print("Gefundene Label-Werte:", dict(labels))
    if not any(is_attack(r["label"]) for r in rows):
        print("WARNUNG: Kein Label wurde als Angriff erkannt. "
              "Bitte POSITIVE_LABELS oben im Skript anpassen.")

    abschnitte = [
        ("Gesamt", ["alle"], [kennzahlen(rows)]),
        ("Je Split", *gruppiert(rows, "split")),
        ("Je harmless_level", *gruppiert(rows, "harmless_level")),
    ]

    hoehen = [len(zeilen) + 2 for _, zeilen, _ in abschnitte]
    fig, axes = plt.subplots(len(abschnitte), 1,
                             figsize=(14, 0.4 * sum(hoehen) + 1.5),
                             gridspec_kw={"height_ratios": hoehen})
    fig.suptitle("Prompt-Injection-Erkennung mit Qwen3.5 (9B)",
                 fontsize=14, fontweight="bold")

    for ax, (titel, zeilen, daten) in zip(axes, abschnitte):
        zeichne_tabelle(ax, titel, zeilen, daten)

    fig.tight_layout()
    fig.savefig(OUT_FILE, dpi=200, bbox_inches="tight")
    print(f"Gespeichert unter {OUT_FILE}")
    plt.show()


if __name__ == "__main__":
    main()