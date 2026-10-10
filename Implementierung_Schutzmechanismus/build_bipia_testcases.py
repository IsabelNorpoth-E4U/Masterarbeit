# Builds the external test set data/bipia_testcases.jsonl
# in the same format as data/testcases.jsonl, so metrics.py works.
#
#   BIPIA (Yi et al., KDD 2025): e-mails, tables and code answers.
#     attack: an attack sentence is put into the text (start, middle or end)
#     harmless_level "normal": the same kind of text without an attack
#   NotInject (Li et al., ACL 2025):
#     harmless_level "hard_negative": harmless prompts with words like "ignore"
#
# Before:  git clone https://github.com/microsoft/BIPIA.git   data/external/BIPIA
#          git clone https://github.com/leolee99/PIGuard.git  data/external/PIGuard
# Run:     python3 build_bipia_testcases.py

import json
import random

BIPIA_DIR = "data/external/BIPIA/benchmark/"
NOTINJECT_DIR = "data/external/PIGuard/datasets/"
OUT_FILE = "data/bipia_testcases.jsonl"

# same seed as in BIPIA, so the random choices are always the same
random.seed(2023)

# texts without attack for every task
CLEAN_PER_TASK = 50

# task and the file with its attacks (code gets code attacks, like in BIPIA)
TASKS = [
    ["email", "text_attack_test.json"],
    ["table", "text_attack_test.json"],
    ["code", "code_attack_test.json"],
]


# reads a jsonl file (one JSON per line)
def load_jsonl(file_name):
    rows = []
    with open(file_name, encoding="utf-8") as file:
        for line in file:
            if line.strip() != "":
                rows.append(json.loads(line))
    return rows


def load_json(file_name):
    with open(file_name, encoding="utf-8") as file:
        return json.load(file)


# the code task has a list of lines, the other tasks have one text
def get_text(sample):
    if type(sample["context"]) == list:
        return "\n".join(sample["context"])
    return sample["context"]


# "Marketing & Advertising" -> "MarketingAdvertising"
# (metrics.py uses the part after the first "-" of the id as group)
def short_name(category):
    name = ""
    for character in category:
        if character.isalnum():
            name = name + character
    return name


# puts the attack into the text, like BIPIA does it.
# middle: before a random sentence (a sentence starts after ". " or a new line)
def insert_attack(text, attack, position):
    if position == "start":
        return attack + "\n" + text
    if position == "end":
        return text + "\n" + attack

    sentence_starts = [0]
    for i in range(len(text) - 1):
        if text[i] == "\n" or (text[i] in ".!?" and text[i + 1] == " "):
            sentence_starts.append(i + 1)
    start = random.choice(sentence_starts)
    return text[:start] + "\n" + attack + "\n" + text[start:]


testcases = []

for task in TASKS:
    task_name = task[0]
    samples = load_jsonl(BIPIA_DIR + task_name + "/test.jsonl")
    attacks = load_json(BIPIA_DIR + task[1])

    # attacks: every attack sentence once, in a random text at a random position
    number = 0
    for category in attacks:
        for attack in attacks[category]:
            number = number + 1
            index = random.randrange(len(samples))
            position = random.choice(["start", "middle", "end"])
            text = insert_attack(get_text(samples[index]), attack, position)
            seed_id = task_name + str(index)

            testcases.append({
                "id": seed_id + "-" + short_name(category) + "-" + position + "-" + str(number),
                "seed_id": seed_id,
                "label": "attack",
                "harmless_level": None,
                "messages": [{"role": "user", "content": text}],
                "split": "test",
                "source": "BIPIA",
                "task": task_name,
                "attack_category": category,
                "position": position,
            })

    # harmless: random texts without attack
    indexes = list(range(len(samples)))
    random.shuffle(indexes)
    for index in indexes[:CLEAN_PER_TASK]:
        seed_id = task_name + str(index)

        testcases.append({
            "id": seed_id + "-clean",
            "seed_id": seed_id,
            "label": "harmless",
            "harmless_level": "normal",
            "messages": [{"role": "user", "content": get_text(samples[index])}],
            "split": "test",
            "source": "BIPIA",
            "task": task_name,
            "attack_category": None,
            "position": None,
        })

# NotInject: three files with one, two or three trigger words
for part in ["one", "two", "three"]:
    samples = load_json(NOTINJECT_DIR + "NotInject_" + part + ".json")
    for i in range(len(samples)):
        seed_id = "notinject_" + part + str(i)

        testcases.append({
            "id": seed_id + "-notinject",
            "seed_id": seed_id,
            "label": "harmless",
            "harmless_level": "hard_negative",
            "messages": [{"role": "user", "content": samples[i]["prompt"]}],
            "split": "test",
            "source": "NotInject",
            "task": "prompt",
            "attack_category": None,
            "position": None,
        })

with open(OUT_FILE, "w", encoding="utf-8") as file:
    for testcase in testcases:
        file.write(json.dumps(testcase, ensure_ascii=False) + "\n")

print("Saved as", OUT_FILE)
print("Number of test cases:", len(testcases))
