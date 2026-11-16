# Makes the attack part of the external appendix (anhang_extern.tex, chapter 4 of the thesis):
#   1. converts every chat (chats_angriffe/*.html) with Microsoft Edge into a PDF
#      (chats_angriffe_pdf/*.pdf), so the chats look like in the browser
#   2. writes the external contents of the attacks as text files into externe_inhalte/
#      (JSON of the multiturn injection, the three ReadMe files of the document injection;
#       text of the Word files json_multiturn.docx and example_ReadMe*.docx)
#   3. writes chats_angriffe.tex: one section per attack (order of chapter 4) with the
#      external contents first and then every page of the chat PDFs as a picture
#
# Run in this folder:  py build_chat_appendix.py
# Then compile:        latexmk -pdf anhang_extern.tex

import html
import os
import re
import subprocess
import tempfile
import time
import zipfile
from pathlib import Path

EDGE = "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
CHAT_DIR = "chats_angriffe"
PDF_DIR = "chats_angriffe_pdf"
TEXT_DIR = "externe_inhalte"
FIG_DIR = "../../figs/04"

# name of the attack for the first part of the file name (like the sections of chapter 4)
ATTACKS = {
    "1": "E-Mail Injection",
    "2": "Multiturn Injection",
    "3": "Website Injection",
    "4": "Encoding Injection",
    "5": "Multi-Modal Injection",
    "6": "Document Injection",
    "7": "URL-Parameter Injection",
}

# external contents of the attacks: [kind, file, caption]
#   "docx":  text of a Word file, printed as listing
#   "image": picture from figs/04
EXTERNAL = {
    "2": [
        ["docx", "json_multiturn.docx", "Fiktiver Chatverlauf im JSON-Format"],
    ],
    "5": [
        ["image", "multi_modal_1", "Bild 1 der Multi-Modal Injection"],
        ["image", "multi_modal_2", "Bild 2 der Multi-Modal Injection"],
        ["image", "multi_modal_3", "Bild 3 der Multi-Modal Injection"],
    ],
    "6": [
        ["docx", "example_ReadMe.docx", "ReadMe-Datei der Document Injection, Versuch 1"],
        ["docx", "example_ReadMe_2.docx", "ReadMe-Datei der Document Injection, Versuch 2"],
        ["docx", "example_ReadMe_3.docx", "ReadMe-Datei der Document Injection, Versuch 3"],
    ],
}


# ---------- 1. chats as PDF ----------

# Edge prints the html page into a PDF, without a browser window.
# Edge can return before the PDF is written, so we wait for the file (at most 60 s).
def html_to_pdf(html_file, pdf_file):
    if os.path.exists(pdf_file):
        os.remove(pdf_file)
    # Edge needs a folder for its settings, it is put into the temp folder of Windows
    profile = Path(tempfile.gettempdir(), "edge_profile_chat_appendix")
    subprocess.run([
        EDGE, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
        "--user-data-dir=" + str(profile),
        "--print-to-pdf=" + str(Path(pdf_file).resolve()),
        Path(html_file).resolve().as_uri(),
    ])
    for second in range(60):
        if os.path.exists(pdf_file) and os.path.getsize(pdf_file) > 0:
            time.sleep(1)  # let Edge finish writing
            return
        time.sleep(1)
    raise SystemExit("Edge did not write " + pdf_file)


# number of pages of a PDF (Edge writes every page as "/Type /Page")
def count_pages(pdf_file):
    data = Path(pdf_file).read_bytes()
    return len(re.findall(rb"/Type\s*/Page[^s]", data))


# ---------- 2. external contents as text ----------

# characters that listings cannot print with pdflatex. Emojis are left out,
# the other characters (äöüß, §, °, „, “, ...) are handled by \lstset literate
# in anhang_extern.tex.
REPLACE = {
    "😊": "", "🌦": "", "☔": "", "💡": "", "🎉": "", "✅": "", "❌": "", "⚠": "", "🛠": "",
    "\ufe0f": "", "’": "'", "\u00a0": " ",
}


# Some lines of the JSON have thousands of characters (long answers of the chatbot).
# listings cannot handle such long lines, so they are split at a space
# into lines of at most 110 characters.
def wrap_line(line):
    pieces = []
    while len(line) > 110:
        cut = line.rfind(" ", 0, 110)
        if cut <= 0:
            cut = 110
        pieces.append(line[:cut])
        line = "    " + line[cut:].lstrip()
    pieces.append(line)
    return pieces


# text of a Word file: every paragraph is one line, line breaks inside a paragraph
# (<w:br/>) are new lines, numbered paragraphs get their number again ("1. ")
def docx_text(docx_file):
    try:
        with zipfile.ZipFile(docx_file) as docx:
            xml = docx.read("word/document.xml").decode("utf-8")
    except PermissionError:
        raise SystemExit("Cannot read " + docx_file + " - please close it in Word and run again.")

    lines = []
    number = 0
    for paragraph in re.findall(r"<w:p[ >].*?</w:p>", xml, flags=re.S):
        paragraph = re.sub(r"<w:br/>", "<w:t>\n</w:t>", paragraph)
        paragraph = re.sub(r"<w:tab/>", "<w:t>    </w:t>", paragraph)
        text = "".join(re.findall(r"<w:t[^>]*>(.*?)</w:t>", paragraph, flags=re.S))
        text = html.unescape(text)
        for old in REPLACE:
            text = text.replace(old, REPLACE[old])
        if "<w:numPr>" in paragraph:
            number = number + 1
            text = str(number) + ". " + text
        else:
            number = 0
        for line in text.split("\n"):
            lines = lines + wrap_line(line)

    # no empty lines at the start and at the end
    while lines and lines[0].strip() == "":
        lines.pop(0)
    while lines and lines[-1].strip() == "":
        lines.pop()
    return lines


# writes the text of the Word file into externe_inhalte/ and returns the new file name
def write_text_file(docx_file):
    if docx_file.startswith("json"):
        ending = ".json"
    else:
        ending = ".txt"
    text_file = TEXT_DIR + "/" + docx_file.replace(".docx", ending)
    Path(text_file).write_text("\n".join(docx_text(docx_file)) + "\n", encoding="utf-8")
    print("Saved as", text_file)
    return text_file


# ---------- 3. chats_angriffe.tex ----------

def tex_name(text):
    return text.replace("_", r"\_")


def external_tex(number):
    lines = [r"\subsection{Externe Inhalte}"]
    for kind, file_name, caption in EXTERNAL[number]:
        if kind == "docx":
            text_file = write_text_file(file_name)
            label = "lst:" + Path(text_file).stem
            lines.append(r"\lstinputlisting[caption={" + caption + " ("
                         + tex_name(Path(text_file).name) + r")}, label={" + label + "}]{"
                         + text_file + "}")
        else:
            lines.append(r"\begin{figure}[H]")
            lines.append(r"\centering")
            lines.append(r"\includegraphics[width=0.7\textwidth]{" + FIG_DIR + "/" + file_name + "}")
            lines.append(r"\caption{" + caption + r"}\label{fig:" + file_name + "}")
            lines.append(r"\end{figure}")
    lines.append(r"\clearpage")
    lines.append("")
    return lines


def chat_tex(file_name, pages, first_in_chapter):
    name = file_name.replace(".html", "")
    attempt = file_name.split("versuch_")[1].replace(".html", "")
    lines = [r"\subsection{Chatverlauf Versuch " + attempt + r"}\label{sec:chat_" + name + "}"]
    for page in range(1, pages + 1):
        # the first page is a bit smaller, so it fits under the headings
        # (even smaller under the big chapter heading)
        if page == 1 and first_in_chapter:
            height = "0.65"
        elif page == 1:
            height = "0.82"
        else:
            height = "0.95"
        lines.append(r"\begin{center}")
        lines.append(r"\includegraphics[page=" + str(page) + r", width=\textwidth, height="
                     + height + r"\textheight, keepaspectratio]{" + PDF_DIR + "/" + name + ".pdf}")
        lines.append(r"\end{center}")
        lines.append(r"\clearpage")
    lines.append("")
    return lines


def write_chat_tex(chats):
    lines = [
        "% made by build_chat_appendix.py, do not change by hand",
        r"\chapter{Angriffe auf den Chatbot}\label{ch:anhang_chats}",
        "",
    ]
    first_in_chapter = True
    for number in ATTACKS:
        lines.append(r"\section{" + ATTACKS[number] + r"}\label{sec:anhang_angriff_" + number + "}")
        lines.append("")
        if number in EXTERNAL:
            lines = lines + external_tex(number)
            first_in_chapter = False
        for file_name, pages in chats:
            if file_name.split("_")[0] == number:
                lines = lines + chat_tex(file_name, pages, first_in_chapter)
                first_in_chapter = False
    Path("chats_angriffe.tex").write_text("\n".join(lines), encoding="utf-8")
    print("Saved as chats_angriffe.tex")


# ---------- start ----------

os.makedirs(PDF_DIR, exist_ok=True)
os.makedirs(TEXT_DIR, exist_ok=True)

chats = []
for file_name in sorted(os.listdir(CHAT_DIR)):
    if not file_name.endswith(".html"):
        continue
    html_file = os.path.join(CHAT_DIR, file_name)
    pdf_file = os.path.join(PDF_DIR, file_name.replace(".html", ".pdf"))
    # only convert again if the html file was changed after the PDF was made
    if not os.path.exists(pdf_file) or os.path.getmtime(html_file) > os.path.getmtime(pdf_file):
        html_to_pdf(html_file, pdf_file)
    pages = count_pages(pdf_file)
    print(file_name, "->", pages, "pages")
    chats.append([file_name, pages])

write_chat_tex(chats)
