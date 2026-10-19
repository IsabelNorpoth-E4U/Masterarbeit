# Experiment: does the majority vote (step B) help for external content,
# if the attacks in the documents are obfuscated?
#
# Data: BIPIA with obfuscated attack sentences (build_bipia_testcases.py --obfuscated),
#       T01, T02, T03, T08 and T14 of the own data set, 40 attacks each.
#
# The functions of the frozen approach (main_new_approach_mistral.py, version 2) are
# loaded without running it, so the experiment uses exactly the same code.
# For every text all answers are collected once:
#   B   guard JA/NEIN for the views V0, VN, VS
#   C   guiding questions on the whole text (original and VN)
#   E   numbered lines on the original
#   E2  numbered lines on the cleaned text VN (only if VN is different)
# The variants are then compared without new api requests:
#   version 2                E or C                 (the frozen approach)
#   version 2 + B            B or E or C
#   version 2 + B if cleaned (B, if VN is different from the original) or E or C
#   version 2 + E on VN      E or E2 or C
#
# Requirement: python3 -m pip install mistralai pyspellchecker
# Data:        python3 build_bipia_testcases.py --dev --obfuscated
# Run:         python3 experiment_obfuscated_bipia_mistral.py
# Only the evaluation again (no api calls): python3 experiment_obfuscated_bipia_mistral.py --evaluate

import json
import os
import sys
import time

from spellchecker import SpellChecker

import metrics

# development data first, the test data stays unseen
TESTCASES_FILE = "data/bipia_dev_obfuscated_testcases.jsonl"
RESULTS_FILE = "results/mistral_small4_bipia_dev_obfuscated_experiment_results.jsonl"

# test data, only once after the decision
# TESTCASES_FILE = "data/bipia_obfuscated_testcases.jsonl"
# RESULTS_FILE = "results/mistral_small4_bipia_obfuscated_experiment_results.jsonl"


# ---------- the functions of the frozen approach ----------

# everything before "start" defines functions and prompts, nothing is run
with open("main_new_approach_mistral.py", encoding="utf-8") as file:
    frozen_code = file.read().split("# ---------- start ----------")[0]
approach = {"__name__": "frozen_approach"}
exec(compile(frozen_code, "main_new_approach_mistral.py", "exec"), approach)

# BIPIA is English, so the spelling correction (view VS) uses the English dictionary
approach["SPELL"] = SpellChecker(language="en", distance=1)


# ---------- one text: collect all answers ----------

def check_text(text):
    start_time = time.time()

    # step A: the views
    normalized = approach["normalize"](text)
    corrected = approach["per_word"](normalized, approach["correct_word"])

    # step B: guard vote for every different view
    view_v0 = approach["make_view"](text, [])
    view_vn = approach["make_view"](normalized, [view_v0])
    view_vs = approach["make_view"](corrected, [view_v0, view_vn])

    # step C: guiding questions on the whole text, with VN as reading help
    questions = approach["question_answers"](text, normalized)

    # step E on the original, and on VN if the cleaning changed the text
    requests, lines_answer = approach["line_check"](text)
    requests_vn = None
    lines_answer_vn = None
    if normalized != text:
        requests_vn, lines_answer_vn = approach["line_check"](normalized)

    return {
        "prompt": text,
        "input_type": "external",
        "cleaned": normalized,
        "cleaning_changed_text": normalized != text,
        "views": {"V0": view_v0, "VN": view_vn, "VS": view_vs},
        "questions_ok": questions is not None,
        "questions": approach["usable_questions"](questions),
        "requests": requests,
        "lines_answer": lines_answer,
        "requests_vn": requests_vn,
        "lines_answer_vn": lines_answer_vn,
        "latency_ms": round((time.time() - start_time) * 1000, 1),
        "score": None,
    }


# ---------- the variants ----------

def majority_vote(row):
    votes, number_of_views = approach["count_votes"](row)
    return votes / number_of_views > approach["GAMMA"]


def lines_vote(row):
    return approach["line_vote"](row["requests"])


def lines_vote_vn(row):
    if not row["cleaning_changed_text"]:
        return False
    return approach["line_vote"](row["requests_vn"])


def questions_vote(row):
    return approach["question_vote"](row)


def version_2(row):
    return lines_vote(row) or questions_vote(row)


def version_2_with_b(row):
    return majority_vote(row) or version_2(row)


def version_2_with_b_if_cleaned(row):
    return (row["cleaning_changed_text"] and majority_vote(row)) or version_2(row)


def version_2_with_e_on_vn(row):
    return version_2(row) or lines_vote_vn(row)


# name, decision; the single steps are shown too, to see what each one adds
VARIANTS = [
    ["only B (majority vote)", majority_vote],
    ["only E (lines)", lines_vote],
    ["only C (guiding questions)", questions_vote],
    ["version 2: E or C", version_2],
    ["version 2 + B", version_2_with_b],
    ["version 2 + B if cleaned", version_2_with_b_if_cleaned],
    ["version 2 + E on VN", version_2_with_e_on_vn],
]


# ---------- files ----------

def load_jsonl(file_name):
    rows = []
    if not os.path.exists(file_name):
        return rows
    with open(file_name, encoding="utf-8") as file:
        for line in file:
            if line.strip() != "":
                rows.append(json.loads(line))
    return rows


# api run for all test cases, the answers are saved after every test case
def run_all():
    testcases = load_jsonl(TESTCASES_FILE)
    os.makedirs("results", exist_ok=True)

    done = []
    for row in load_jsonl(RESULTS_FILE):
        done.append(row["id"])

    print("Model:", approach["MODEL"])
    print("Number of test cases:", len(testcases))
    print("Already done:", len(done))

    number = 0
    for testcase in testcases:
        number = number + 1
        if testcase["id"] in done:
            continue

        row = check_text(testcase["messages"][-1]["content"])
        for field in ["id", "seed_id", "split", "label", "harmless_level",
                      "source", "task", "attack_category", "position", "transformation"]:
            if field in testcase:
                row[field] = testcase[field]

        with open(RESULTS_FILE, "a", encoding="utf-8") as file:
            file.write(json.dumps(row, ensure_ascii=False) + "\n")

        print(number, "/", len(testcases), testcase["id"],
              "B", majority_vote(row), "E", lines_vote(row), "C", questions_vote(row))


# ---------- evaluation ----------

# the metrics of every variant (recall per transformation, false positive rate)
def evaluate():
    rows = load_jsonl(RESULTS_FILE)
    if len(rows) == 0:
        raise SystemExit("No results yet. Run first: python3 experiment_obfuscated_bipia_mistral.py")

    split = rows[0]["split"]
    for name, decide in VARIANTS:
        for row in rows:
            row["flagged"] = decide(row)
        result = metrics.compute(rows, split=split, run=name)
        metrics.report(result)


# so that special characters (for example invisible characters) can be printed
sys.stdout.reconfigure(encoding="utf-8")

if len(sys.argv) > 1 and sys.argv[1] == "--evaluate":
    evaluate()
else:
    run_all()
    evaluate()
