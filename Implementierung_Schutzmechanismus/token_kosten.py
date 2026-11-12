# Number of tokens, costs and latency of the eight test runs (section 6.3 "Latenz und Kosten").
#
# The api answers were saved without the token usage, so the requests are built again
# from the result files: the same system prompt and the same user text as in
# main_original_mistral.py and main_new_approach_mistral.py. The tokens are counted
# with the tokenizer of the model (mistral-common, with the chat template).
#   input tokens:  system prompt + user text + chat template
#   output tokens: the saved answer + end of the answer (</s>). For the guiding
#                  questions and the numbered lines the JSON answer is written again
#                  from the saved values, in the form given in the prompt.
# Not counted: repeated requests after an error of the api.
#
# Requirement: python3 -m pip install mistral-common huggingface_hub
# Run:         python3 token_kosten.py
#
# Writes: results_diagramms/mistral_small4_test_new_approach_vs_original_tabelle_token_kosten.tex

import ast
import json

from mistral_common.protocol.instruct.messages import SystemMessage, UserMessage
from mistral_common.protocol.instruct.request import ChatCompletionRequest
from mistral_common.tokens.tokenizers.mistral import MistralTokenizer

# the prompts are read from the scripts, importing them would start the api run
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

# price in dollar per one million tokens (input, output), see section 5
PRICES = {
    "mistral_small4": (0.15, 0.60),
    "mistral_large4": (1.36, 4.16),
}

TOKENIZERS = {
    "mistral_small4": MistralTokenizer.from_hf_hub("mistralai/Mistral-Small-4-119B-2603"),
    "mistral_large4": MistralTokenizer.from_hf_hub("mistralai/Mistral-Large-4-1T-A52B"),
}

# the runs of table tab:ergebnisse: (data set, approach, model, result file)
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


# the user text of the guiding questions, like question_answers() in main_new_approach_mistral.py
def question_text(text):
    user_text = "Nachricht:\n<<<\n" + text + "\n>>>\n\nFragen:\n"
    for name in NEW["QUESTIONS"]:
        user_text = user_text + name + ": " + NEW["QUESTIONS"][name] + "\n"
    return user_text


# the same as number_lines() in main_new_approach_mistral.py
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


# the user text of the numbered lines, like line_check() in main_new_approach_mistral.py
def lines_text(text):
    return "Text:\n<<<\n" + number_lines(text) + "\n>>>"


# number of input tokens of one request (with the chat template)
def input_tokens(model, system_prompt, user_text):
    messages = [SystemMessage(content=system_prompt), UserMessage(content=user_text)]
    # the template of Mistral Large 4 has no "none", there the setting is left out
    if model == "mistral_small4":
        request = ChatCompletionRequest(messages=messages, reasoning_effort="none")
    else:
        request = ChatCompletionRequest(messages=messages)
    return len(TOKENIZERS[model].encode_chat_completion(request).tokens)


# number of output tokens of one answer, +1 for the end of the answer
def output_tokens(model, answer):
    tokenizer = TOKENIZERS[model].instruct_tokenizer.tokenizer
    return len(tokenizer.encode(answer, bos=False, eos=False)) + 1


# the JSON answer of the guiding questions, in the form of QUESTION_PROMPT
def questions_answer(questions):
    data = {}
    for name in questions:
        data[name] = "JA" if questions[name] else "NEIN"
    return json.dumps(data, ensure_ascii=False)


# the JSON answer of the numbered lines, in the form of LINES_PROMPT
def lines_answer(requests):
    return json.dumps({"aufforderungen": requests}, ensure_ascii=False)


# all requests of one test case of the original approach: (input, output)
def requests_original(model, row):
    return [(input_tokens(model, ORIGINAL["GUARD_PROMPT"], "Nutzereingabe: " + row["prompt"]),
             output_tokens(model, row["answer"]))]


# all requests of one test case of the new approach: (input, output)
# views with "same_as" were not sent again
def requests_new_approach(model, row):
    requests = []
    external = row["input_type"] == "external"
    for name in ["V0", "VN", "VS"]:
        view = row["views"][name]
        if "same_as" not in view:
            requests.append((input_tokens(model, NEW["QUESTION_PROMPT"],
                                          question_text(view["text"])),
                             output_tokens(model, questions_answer(view["questions"]))))
            if not external:
                requests.append((input_tokens(model, NEW["GUARD_PROMPT"],
                                              "Nutzereingabe: " + view["text"]),
                                 output_tokens(model, view["guard_answer"])))
        # numbered lines on V0 and VN, VN only if it is different from V0
        if external and name in ["V0", "VN"] and "same_as" not in view:
            requests.append((input_tokens(model, NEW["LINES_PROMPT"],
                                          lines_text(view["text"])),
                             output_tokens(model, lines_answer(view["requests"]))))
    return requests


# German number format: 1.234.567 and 0,12
def number_de(value, decimals=0):
    text = f"{value:,.{decimals}f}"
    return text.replace(",", "X").replace(".", "{,}").replace("X", ".")


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
        for request_in, request_out in requests:
            tokens_in = tokens_in + request_in
            tokens_out = tokens_out + request_out

    price_in, price_out = PRICES[model]
    cost = tokens_in / 1e6 * price_in + tokens_out / 1e6 * price_out
    # median like in metrics.py
    latencies.sort()
    return {
        "entries": len(rows),
        "latency_median": latencies[len(latencies) // 2],
        "requests": number_of_requests,
        "tokens_in": tokens_in,
        "tokens_out": tokens_out,
        "tokens_per_entry": (tokens_in + tokens_out) / len(rows),
        "cost": cost,
        "cost_per_1000": cost / len(rows) * 1000,
    }


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
