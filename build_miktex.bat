@echo off
rem Build script for MiKTeX: keeps PDF in project root, aux files in auxil\
if not exist auxil mkdir auxil
if not exist out mkdir out
echo Running pdflatex (1/4)...
pdflatex -interaction=nonstopmode -file-line-error -aux-directory=auxil -output-directory=. hsmw-vorlage.tex
echo Copying .bib to auxil and running biber (2/4)...
copy /Y hsmw-literature.bib auxil\ >nul
biber --input-directory=auxil hsmw-vorlage
echo Running makeindex for nomenclature (3/4)...
makeindex auxil\hsmw-vorlage.nlo -s nomencl.ist -o auxil\hsmw-vorlage.nls
echo Running pdflatex (4/4)...
pdflatex -interaction=nonstopmode -file-line-error -aux-directory=auxil -output-directory=. hsmw-vorlage.tex
pdflatex -interaction=nonstopmode -file-line-error -aux-directory=auxil -output-directory=. hsmw-vorlage.tex
move /Y hsmw-vorlage.pdf out\hsmw-vorlage.pdf
echo Build finished. PDF moved to out\hsmw-vorlage.pdf
