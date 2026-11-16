import ast
import json
import statistics

from mistral_common.protocol.instruct.messages import SystemMessage, UserMessage
from mistral_common.protocol.instruct.request import ChatCompletionRequest
from mistral_common.tokens.tokenizers.mistral import MistralTokenizer

# files are searched for prompts (e.g. GUARD_PROMPT)
# -> creates ORIGINAL and NEW
def read_constants(file_name, names):
    with open(file_name, encoding="utf-8") as file:
        tree = ast.parse(file.read())
    constants = {}
    for node in tree.body:
        if type(node) == ast.Assign and type(node.targets[0]) == ast.Name:
            if node.targets[0].id in names:
                constants[node.targets[0].id] = ast.literal_eval(node.value)
    return constants


ORIGINAL = read_constants("main_original_mistral.py", ["GUARD_PROMPT"])
NEW = read_constants("main_new_approach_mistral.py",
                     ["GUARD_PROMPT", "QUESTION_PROMPT", "QUESTIONS", "LINES_PROMPT"])

TABLE_FILE = ("results_diagramms/"
              "mistral_small4_test_new_approach_vs_original_tabelle_token_kosten.tex")

PRICES = {
    "mistral_small4": (0.15, 0.60),
    "mistral_large4": (1.36, 4.16),
}

TOKENIZERS = {
    "mistral_small4": MistralTokenizer.from_hf_hub("mistralai/Mistral-Small-4-119B-2603"),
    "mistral_large4": MistralTokenizer.from_hf_hub("mistralai/Mistral-Large-4-1T-A52B"),
}

RUNS = [
    ("Eigener Datensatz", "Original (Mistral Small~4)", "mistral_small4",
     "results/mistral_small4_test_original_eigen_results.jsonl"),
    ("Eigener Datensatz", "Original (Mistral Large~4)", "mistral_large4",
     "results/mistral_large4_test_original_eigen_results.jsonl"),
    ("Eigener Datensatz", "Weiterentwickelter Ansatz (Mistral Small~4)", "mistral_small4",
     "results/mistral_small4_test_new_approach_eigen_results.jsonl"),
    ("BIPIA + NotInject", "Original (Mistral Small~4)", "mistral_small4",
     "results/mistral_small4_test_original_bipia_results.jsonl"),
    ("BIPIA + NotInject", "Original (Mistral Large~4)", "mistral_large4",
     "results/mistral_large4_test_original_bipia_results.jsonl"),
    ("BIPIA + NotInject", "Weiterentwickelter Ansatz (Mistral Small~4)", "mistral_small4",
     "results/mistral_small4_test_new_approach_bipia_results.jsonl"),
    ("BIPIA, verschleiert", "Original (Mistral Small~4)", "mistral_small4",
     "results/mistral_small4_test_original_bipia_obfuscated_results.jsonl"),
    ("BIPIA, verschleiert", "Weiterentwickelter Ansatz (Mistral Small~4)", "mistral_small4",
     "results/mistral_small4_test_new_approach_bipia_obfuscated_results.jsonl"),
]

def load_jsonl(file_name):
    rows = []
    with open(file_name, encoding="utf-8") as file:
        for line in file:
            if line.strip() != "":
                rows.append(json.loads(line))
    return rows

# builds request like question_answers() in main_new_approach_mistral.py
def question_text(text):
    user_text = "Nachricht:\n<<<\n" + text + "\n>>>\n\nFragen:\n"
    for name in NEW["QUESTIONS"]:
        user_text = user_text + name + ": " + NEW["QUESTIONS"][name] + "\n"
    return user_text

# same as number_lines() in main_new_approach_mistral.py
def number_lines(text):
    sentences = []
    for line in text.split("\n"):
        sentence = ""
        for i in range(len(line)):
            sentence = sentence + line[i]
            if line[i] in ".!?" and i + 1 < len(line) and line[i + 1] == " ":
                sentences.append(sentence)
                sentence = ""
        sentences.append(sentence)

    numbered = []
    number = 0
    for sentence in sentences:
        sentence = sentence.strip()
        if sentence == "":
            continue
        number = number + 1
        numbered.append("[" + str(number) + "] " + sentence)
    return "\n".join(numbered)

# build request with systemprompt an usertext and counts token
def input_tokens(model, system_prompt, user_text):
    messages = [SystemMessage(content=system_prompt), UserMessage(content=user_text)]
    # the template of Mistral Large 4 has no "none", there the setting is left out
    if model == "mistral_small4":
        request = ChatCompletionRequest(messages=messages, reasoning_effort="none")
    else:
        request = ChatCompletionRequest(messages=messages)
    return len(TOKENIZERS[model].encode_chat_completion(request).tokens)

# counts output token of the answer
# +1 because every answer is </s>
def output_tokens(model, answer):
    tokenizer = TOKENIZERS[model].instruct_tokenizer.tokenizer
    return len(tokenizer.encode(answer, bos=False, eos=False)) + 1

# builds json answer with saved ja/nein
def questions_answer(questions):
    data = {}
    for name in questions:
        if questions[name]:
            data[name] = "JA"
        else:
            data[name] = "NEIN"
    return json.dumps(data, ensure_ascii=False)

# original approach sends one request -> function returns pair of (input, output)
def requests_original(model, row):
    tokens_in = input_tokens(model, ORIGINAL["GUARD_PROMPT"], "Nutzereingabe: " + row["prompt"])
    tokens_out = output_tokens(model, row["answer"])
    return [(tokens_in, tokens_out)]

# all requests of one test case of the new approach: (input, output)
# views with "same_as" were not sent again
def requests_new_approach(model, row):
    requests = []
    for name in ["V0", "VN", "VS"]:
        view = row["views"][name]
        if "same_as" in view:
            continue

        # guiding questions
        tokens_in = input_tokens(model, NEW["QUESTION_PROMPT"], question_text(view["text"]))
        tokens_out = output_tokens(model, questions_answer(view["questions"]))
        requests.append((tokens_in, tokens_out))

        if row["input_type"] == "external":
            # numbered lines, only on V0 and VN
            if name != "VS":
                # like line_check() in main_new_approach_mistral.py,
                # the JSON answer in the form of LINES_PROMPT
                user_text = "Text:\n<<<\n" + number_lines(view["text"]) + "\n>>>"
                answer = json.dumps({"aufforderungen": view["requests"]}, ensure_ascii=False)
                tokens_in = input_tokens(model, NEW["LINES_PROMPT"], user_text)
                tokens_out = output_tokens(model, answer)
                requests.append((tokens_in, tokens_out))
        else:
            # guard prompt
            tokens_in = input_tokens(model, NEW["GUARD_PROMPT"], "Nutzereingabe: " + view["text"])
            tokens_out = output_tokens(model, view["guard_answer"])
            requests.append((tokens_in, tokens_out))
    return requests

# change number format from englisch to german -> to put result in text
def number_de(value, decimals=0):
    text = format(value, ",." + str(decimals) + "f")
    text = text.replace(",", "X")
    text = text.replace(".", "{,}")
    text = text.replace("X", ".")
    return text

# main function for token counting process
def count_run(model, file_name):
    rows = load_jsonl(file_name)
    number_of_requests = 0
    tokens_in = 0
    tokens_out = 0
    latencies = []
    for row in rows:
        latencies.append(row["latency_ms"])
        if "views" in row:
            requests = requests_new_approach(model, row)
        else:
            requests = requests_original(model, row)
        number_of_requests = number_of_requests + len(requests)
        for request in requests:
            tokens_in = tokens_in + request[0]
            tokens_out = tokens_out + request[1]

    price_in = PRICES[model][0]
    price_out = PRICES[model][1]
    cost = tokens_in / 1000000 * price_in + tokens_out / 1000000 * price_out
    # median like in metrics.py (mean of the two middle values for an even number)
    return {
        "entries": len(rows),
        "latency_median": statistics.median(latencies),
        "requests": number_of_requests,
        "tokens_in": tokens_in,
        "tokens_out": tokens_out,
        "tokens_per_entry": (tokens_in + tokens_out) / len(rows),
        "cost": cost,
        "cost_per_1000": cost / len(rows) * 1000,
    }

# build table for text
lines = [
    r"\begin{tabular}{l r r r r r r r r}",
    r"\toprule",
    r"\textbf{Ansatz} & \textbf{Einträge} & \textbf{Anfragen} & \textbf{Input-Token}"
    r" & \textbf{Output-Token} & \textbf{Token/Eintrag} & \textbf{Kosten}"
    r" & \textbf{Kosten/1000 Einträge} & \textbf{Latenz (Median)} \\",
    r"\midrule",
]
total = {"requests": 0, "tokens_in": 0, "tokens_out": 0, "cost": 0}
data_set = None
for run_data_set, approach, model, file_name in RUNS:
    result = count_run(model, file_name)
    for key in total:
        total[key] = total[key] + result[key]
    print(run_data_set, "|", approach, "|", result)

    if run_data_set != data_set:
        if data_set is not None:
            lines.append(r"\midrule")
        lines.append(r"\multicolumn{9}{l}{\textit{" + run_data_set + r"}} \\")
        data_set = run_data_set
    name = approach
    if approach.startswith("Weiterentwickelter"):
        name = r"\textbf{" + approach + "}"
    lines.append(name
                 + " & " + number_de(result["entries"])
                 + " & " + number_de(result["requests"])
                 + " & " + number_de(result["tokens_in"])
                 + " & " + number_de(result["tokens_out"])
                 + " & " + number_de(result["tokens_per_entry"])
                 + " & " + number_de(result["cost"], 3) + r"\,\$"
                 + " & " + number_de(result["cost_per_1000"], 3) + r"\,\$"
                 + " & " + number_de(result["latency_median"]) + r"\,ms \\")

lines.append(r"\midrule")
lines.append(r"\textbf{Gesamt} & & " + number_de(total["requests"])
             + " & " + number_de(total["tokens_in"])
             + " & " + number_de(total["tokens_out"])
             + " & & " + number_de(total["cost"], 3) + r"\,\$ & & \\")
lines.append(r"\bottomrule")
lines.append(r"\end{tabular}")

with open(TABLE_FILE, "w", encoding="utf-8") as file:
    file.write("\n".join(lines) + "\n")
print("total:", total)
print("written:", TABLE_FILE)
