# Makes the appendix of the attack chats (chapter 4):
#   1. converts every chat (chats_angriffe/*.html) with Microsoft Edge into a PDF
#      (chats_angriffe_pdf/*.pdf), so the chats look like in the browser
#   2. writes chats_angriffe.tex, which shows every page of these PDFs as a picture
#   3. writes json_multiturn.tex with the JSON of the multiturn injection
#      (text of json_multiturn.docx)
#
# Run in this folder:  python3 build_chat_appendix.py
# Then in hsmw-vorlage-rw.tex:  \input{appendix/json_multiturn.tex}
#                               \input{appendix/chats_angriffe.tex}

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
JSON_DOCX = "json_multiturn.docx"

# name of the attack for the first part of the file name (like the sections of chapter 4)
ATTACKS = {
    "1": "E-Mail Injection",
    "2": "Multiturn Injection",
    "3": "Website Injection",
    "4": "Jailbreak Prompt",
    "5": "Multi-Modal Injection",
    "6": "Document Injection",
    "7": "URL-Parameter Injection",
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


# "2_multiturn_versuch_1.html" -> "Multiturn Injection, Versuch 1"
def chat_title(file_name):
    number = file_name.split("_")[0]
    attempt = file_name.split("versuch_")[1].replace(".html", "")
    return ATTACKS[number] + ", Versuch " + attempt


def write_chat_tex(chats):
    lines = [
        "% made by build_chat_appendix.py, do not change by hand",
        r"\chapter{Chatverläufe der Angriffe}\label{ch:anhang_chats}",
        "",
    ]
    for file_name, pages in chats:
        name = file_name.replace(".html", "")
        lines.append(r"\section{" + chat_title(file_name) + r"}\label{sec:chat_" + name + "}")
        for page in range(1, pages + 1):
            # the first page is a bit smaller, so it fits under the heading
            if page == 1:
                height = "0.82"
            else:
                height = "0.95"
            lines.append(r"\begin{center}")
            lines.append(r"\includegraphics[page=" + str(page) + r", width=\textwidth, height="
                         + height + r"\textheight, keepaspectratio]{appendix/" + PDF_DIR + "/"
                         + name + ".pdf}")
            lines.append(r"\end{center}")
            lines.append(r"\clearpage")
        lines.append("")
    Path("chats_angriffe.tex").write_text("\n".join(lines), encoding="utf-8")
    print("Saved as chats_angriffe.tex")


# ---------- 2. the JSON of the multiturn injection ----------

# characters that listings cannot print with pdflatex. Emojis are left out,
# the other characters (äöüß, §, °, „, “, ...) are handled by \lstset literate
# in hsmw-vorlage-rw.tex.
REPLACE = {
    "😊": "", "🌦": "", "☔": "", "💡": "", "🎉": "", "✅": "", "❌": "", "⚠": "", "\ufe0f": "",
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


def write_json_tex():
    try:
        with zipfile.ZipFile(JSON_DOCX) as docx:
            xml = docx.read("word/document.xml").decode("utf-8")
    except PermissionError:
        print("Cannot read", JSON_DOCX, "- please close it in Word and run again.")
        return

    # every paragraph of the Word file is one line of the JSON
    lines = []
    for paragraph in re.findall(r"<w:p[ >].*?</w:p>", xml, flags=re.S):
        text = "".join(re.findall(r"<w:t[^>]*>(.*?)</w:t>", paragraph, flags=re.S))
        text = html.unescape(text)
        for old in REPLACE:
            text = text.replace(old, REPLACE[old])
        lines = lines + wrap_line(text)

    tex = [
        "% made by build_chat_appendix.py, do not change by hand",
        r"\chapter{JSON der Multiturn Injection}\label{ch:anhang_json}",
        "",
        r"\begin{lstlisting}[caption={Fiktiver Chatverlauf im JSON-Format (Multiturn Injection)}, "
        r"label={lst:json_multiturn}]",
    ]
    tex = tex + lines + [r"\end{lstlisting}", ""]
    Path("json_multiturn.tex").write_text("\n".join(tex), encoding="utf-8")
    print("Saved as json_multiturn.tex")


# ---------- start ----------

os.makedirs(PDF_DIR, exist_ok=True)

chats = []
for file_name in sorted(os.listdir(CHAT_DIR)):
    if not file_name.endswith(".html"):
        continue
    pdf_file = os.path.join(PDF_DIR, file_name.replace(".html", ".pdf"))
    html_to_pdf(os.path.join(CHAT_DIR, file_name), pdf_file)
    pages = count_pages(pdf_file)
    print(file_name, "->", pages, "pages")
    chats.append([file_name, pages])

write_chat_tex(chats)
write_json_tex()
