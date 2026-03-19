#!/bin/bash

# remove build directory
rm -rf /build

# Name der Hauptdatei (ohne .tex Erweiterung)
MAIN_FILE="main"

# Verzeichnis für die Ausgabedateien
OUTPUT_DIR="build"

# Erstelle das Ausgabeverzeichnis, falls es nicht existiert
mkdir -p $OUTPUT_DIR

# Befehl zum Kompilieren des LaTeX-Dokuments
pdflatex -output-directory=$OUTPUT_DIR $MAIN_FILE.tex
bibtex $OUTPUT_DIR/$MAIN_FILE
pdflatex -output-directory=$OUTPUT_DIR $MAIN_FILE.tex
pdflatex -output-directory=$OUTPUT_DIR $MAIN_FILE.tex

# Optional: Aufräumen der Hilfsdateien im Ausgabeordner
rm $OUTPUT_DIR/.aux $OUTPUT_DIR/.bbl $OUTPUT_DIR/.blg $OUTPUT_DIR/.log $OUTPUT_DIR/.out $OUTPUT_DIR/.toc