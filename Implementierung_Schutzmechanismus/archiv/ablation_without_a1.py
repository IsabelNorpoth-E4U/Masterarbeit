# Ablation: new approach 2 WITHOUT step A1 (script variants V1 ... V6)
#
# Question: do we need the variants built by the script, or is it enough to
# give the original text directly to the LLM reconstruction (V7)?
#
# Only the test cases where step A1 changed the text are run again, because
# for all other cases the original text already went to the LLM, so the
# result would be the same. s0 is taken from the old run (it never used A1).
#
# This script does not change main_newapproach_mistral_2.py or its result
# files. Everything is written to new files with "ablation_noA1" in the name.
# To undo: delete this script and the files results/*ablation_noA1*.
#
# Run:          python3 ablation_without_a1.py
# Only compare: python3 ablation_without_a1.py --compare

import json
import os
import sys
import time

import metrics


# the functions of the main script are loaded without running its start part
# (otherwise the whole api run of the main script would start)
main_code = open("main_newapproach_mistral_2.py", encoding="utf-8").read()
main_code = main_code.split("# ---------- Start ----------")[0]
main = {}
exec(main_code, main)


OLD_SCORES_FILE = main["SCORES_FILE"]
OLD_RESULTS_FILE = main["RESULTS_FILE"]
OLD_THRESHOLDS_FILE = main["THRESHOLDS_FILE"]

NEW_SCORES_FILE = "results/mistral_small4_newapproach2_ablation_noA1_raw.jsonl"
NEW_RESULTS_FILE = "results/mistral_small4_newapproach2_ablation_noA1_results.jsonl"
NEW_METRICS_FILE = "results/mistral_small4_newapproach2_ablation_noA1_metrics.json"
NEW_THRESHOLDS_FILE = "results/mistral_small4_newapproach2_ablation_noA1_thresholds.json"


# same as check_prompt in the main script, but the original text goes
# directly to the reconstruction (no variants, no most_readable)
def check_prompt_without_a1(old_row):
    start_time = time.time()
    prompt = old_row["prompt"]

    clear_text, grade, llm_techniques = main["reconstruct"](prompt)

    s0 = old_row["s0"]
    if clear_text is not None:
        s_clear = main["guard_score"](clear_text)
        question_text = clear_text
    else:
        s_clear = 1.0
        question_text = prompt

    questions = main["question_scores"](question_text)
    questions_ok = questions is not None
    if not questions_ok:
        questions = {"F0": 0.0, "F1": 1.0, "F2": 1.0, "F3": 1.0, "F4": 1.0, "F5": 1.0}

    f_max_name = "F1"
    for name in ["F1", "F2", "F3", "F4", "F5"]:
        if questions[name] > questions[f_max_name]:
            f_max_name = name

    new_row = {}
    for key in ["id", "seed_id", "split", "label", "harmless_level", "prompt"]:
        new_row[key] = old_row[key]
    new_row["variants"] = {"V0": prompt}
    new_row["readable_variant"] = "V0"
    new_row["clear_text"] = clear_text
    new_row["reconstruction_ok"] = clear_text is not None
    new_row["grade"] = grade
    new_row["llm_techniques"] = llm_techniques
    new_row["s0"] = s0
    new_row["s_clear"] = s_clear
    new_row["delta"] = s_clear - s0
    new_row["questions_ok"] = questions_ok
    new_row["questions"] = questions
    new_row["f_max_name"] = f_max_name
    new_row["f_max"] = questions[f_max_name]
    new_row["score"] = s_clear
    new_row["latency_ms"] = round((time.time() - start_time) * 1000, 1)
    new_row["rerun_without_a1"] = True
    return new_row


# true if step A1 changed the text that went to the LLM
def a1_changed_text(row):
    return row["variants"][row["readable_variant"]] != row["prompt"]


def run_ablation():
    old_rows = main["load_jsonl"](OLD_SCORES_FILE)

    done = []
    for row in main["load_jsonl"](NEW_SCORES_FILE):
        done.append(row["id"])

    todo = 0
    for row in old_rows:
        if a1_changed_text(row):
            todo = todo + 1
    print("Test cases:", len(old_rows), " run again without A1:", todo, " already done:", len(done))

    number = 0
    for old_row in old_rows:
        if old_row["id"] in done:
            continue

        if a1_changed_text(old_row):
            number = number + 1
            new_row = check_prompt_without_a1(old_row)
            print(number, "/", todo, old_row["id"],
                  "s_clear", old_row["s_clear"], "->", new_row["s_clear"],
                  "f_max", old_row["f_max"], "->", new_row["f_max"])
        else:
            # A1 changed nothing, so the old result is also the result without A1
            new_row = dict(old_row)
            new_row["rerun_without_a1"] = False
            for key in ["flagged", "reason"]:
                if key in new_row:
                    del new_row[key]

        with open(NEW_SCORES_FILE, "a", encoding="utf-8") as file:
            file.write(json.dumps(new_row, ensure_ascii=False) + "\n")


def recall_and_fpr(rows, thresholds, split):
    tp = 0
    fp = 0
    attacks = 0
    harmless = 0
    for row in rows:
        if row["split"] != split:
            continue
        flagged, reason = main["decide"](row, thresholds)
        if row["label"] == "attack":
            attacks = attacks + 1
            if flagged:
                tp = tp + 1
        else:
            harmless = harmless + 1
            if flagged:
                fp = fp + 1
    return tp, attacks, fp, harmless


def print_line(name, rows, thresholds):
    for split in ["dev", "test"]:
        tp, attacks, fp, harmless = recall_and_fpr(rows, thresholds, split)
        print("  %-38s %-4s recall %.3f (%d/%d)  FPR %.3f (%d/%d)"
              % (name, split, tp / attacks, tp, attacks, fp / harmless, fp, harmless))


def compare():
    old_rows = main["load_jsonl"](OLD_SCORES_FILE)
    new_rows = main["load_jsonl"](NEW_SCORES_FILE)
    if len(new_rows) != len(old_rows):
        print("Ablation run not complete yet:", len(new_rows), "/", len(old_rows))
        sys.exit()

    with open(OLD_THRESHOLDS_FILE, encoding="utf-8") as file:
        old_thresholds = json.load(file)

    # new thresholds for the version without A1, with the same calibration
    # as the main script (only dev). The calibrate function of the main script
    # is used, but it writes to the new files.
    main["SCORES_FILE"] = NEW_SCORES_FILE
    main["RESULTS_FILE"] = NEW_RESULTS_FILE
    main["METRICS_FILE"] = NEW_METRICS_FILE
    main["THRESHOLDS_FILE"] = NEW_THRESHOLDS_FILE
    main["calibrate"]()
    with open(NEW_THRESHOLDS_FILE, encoding="utf-8") as file:
        new_thresholds = json.load(file)

    print("\n========== Comparison ==========")
    print("Thresholds with A1:   ", old_thresholds)
    print("Thresholds without A1:", new_thresholds)
    print_line("with A1", old_rows, old_thresholds)
    print_line("without A1 (own thresholds)", new_rows, new_thresholds)
    print_line("without A1 (thresholds of with A1)", new_rows, old_thresholds)

    # recall per transformation on test, only where A1 changed something
    print("\nTest attacks where A1 changed the text, per transformation:")
    old_by_id = {}
    for row in old_rows:
        old_by_id[row["id"]] = row
    counts = {}
    for row in new_rows:
        if row["split"] != "test" or row["label"] != "attack" or not row["rerun_without_a1"]:
            continue
        transformation = row["id"].split("-")[1]
        if transformation not in counts:
            counts[transformation] = [0, 0, 0]
        counts[transformation][0] = counts[transformation][0] + 1
        if main["decide"](old_by_id[row["id"]], old_thresholds)[0]:
            counts[transformation][1] = counts[transformation][1] + 1
        if main["decide"](row, new_thresholds)[0]:
            counts[transformation][2] = counts[transformation][2] + 1
    for transformation in sorted(counts):
        n, with_a1, without_a1 = counts[transformation]
        print("  ", transformation, " n", n, " found with A1", with_a1, " without A1", without_a1)


sys.stdout.reconfigure(encoding="utf-8")

if len(sys.argv) > 1 and sys.argv[1] == "--compare":
    compare()
else:
    run_ablation()
    compare()
