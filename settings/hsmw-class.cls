\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{hsmw-class}[2015/10/23 (Klaus Dohmen) and 2017 (Roebbe Wuenschiers)]
% 2017 erweitert von Röbbe Wünschiers

%Optionen

\newif\ifdraft
\draftfalse
\newif\ifloadams
\loadamstrue
\newif\ifnotables
\notablesfalse
\newif\ifnofigures
\nofiguresfalse
\newif\ifnonomenclature
\nonomenclaturetrue
\newif\ifnoindex
\noindextrue
\newif\ifnoglossary
\noglossarytrue
\newif\ifmw@extratitle
\mw@extratitlefalse
\newif\ifsmallromans
\smallromansfalse
\newif\ifoneside
\onesidefalse
\newif\ifEid
\Eidfalse
\newif\ifjubilogo
\jubilogofalse
\newif\ifenglish
\englishfalse
\newif\ifmultiauthor % Röbbe
\multiauthorfalse

\RequirePackage{ifthen}
\RequirePackage{xkeyval}


\newboolean{seplists}
\setboolean{seplists}{true}

\newcounter{firstpage}

% DOCUMENTCLASS
\DeclareOptionX{multiauthor}{\multiauthortrue} % Röbbe
\DeclareOptionX{english}{\def\@englisch{true}}
\DeclareOptionX{thmbelow}{\def\@thmbelow{true}}
\DeclareOptionX{thmpoint}{\def\Trennzeichen{.}}
\DeclareOptionX{thmcolon}{\def\Trennzeichen{:}}
\DeclareOptionX{hypertext}{\def\@hypertext{true}}
\DeclareOptionX{noseplists}{\setboolean{seplists}{false}}
\DeclareOptionX{tablesfirst}{\def\tablesfirst{true}}
\DeclareOptionX{sansmath}{\def\@sansmath{true}}
\DeclareOptionX{minus}{\def\@minussymbol{true}}
\DeclareOptionX{noromanprefix}{\def\@noromansectionnumbers{true}}
\DeclareOptionX{smallromans}[5]{\smallromanstrue\setcounter{firstpage}{#1}}
\DeclareOptionX{draft}{\drafttrue\def\@skiptheme{true}}
\DeclareOptionX{classictoc}{\def\@classictoc{true}}
\DeclareOptionX{bigheadings}{\def\@bigheadings{true}}
\DeclareOptionX{smallheadings}{\def\@smallheadings{true}}
\DeclareOptionX{counttables}{\def\counttables{true}}
\DeclareOptionX{texnote}{\def\@texnote{true}}
\DeclareOptionX{notables}{\notablestrue\setboolean{seplists}{true}}
\DeclareOptionX{nofigures}{\nofigurestrue\setboolean{seplists}{true}}
\DeclareOptionX{nomenclature}{\nonomenclaturefalse}
\DeclareOptionX{index}{\noindexfalse}
\DeclareOptionX{glossary}{\noglossaryfalse}
\DeclareOptionX{norefpage}{\def\@norefpage{true}}
\DeclareOptionX{oneside}{\onesidetrue}
\DeclareOptionX{Eid}{\Eidtrue}
\DeclareOptionX{150}{\jubilogotrue}
\DeclareOptionX*{\PassOptionsToClass{\CurrentOption}{scrbook}}
\ProcessOptionsX\relax

% KOMAScript wird geladen
\ifoneside
\LoadClass[12pt,%
headsepline,%
toc=flat,%
index=toc,
listof=flat,%
listof=nochaptergap,
parskip,
bibliography=totoc,
footnotes=multiple,
headings=normal,
twoside=false,
numbers=noendperiod,%
version=3.04]{scrbook}[2009/07/07]
\RequirePackage[paper=a4paper, inner=35mm, outer=26mm, top=13mm, bottom=28mm, includehead]{geometry}
\else
\LoadClass[12pt,%
headsepline,%
toc=flat,%
index=toc,
listof=flat,%
listof=nochaptergap,
parskip,
bibliography=totoc,
footnotes=multiple,
headings=normal,
numbers=noendperiod,%
version=3.04]{scrbook}[2009/07/07]
\RequirePackage[paper=a4paper, twoside, inner=35mm, outer=26mm, top=13mm, bottom=28mm, includehead]{geometry}
\fi

\ifthenelse{\isundefined{\@englisch}}{%
\RequirePackage[ngerman]{babel}
%\RequirePackage{ngerman} ROBBE
\englishfalse}{\RequirePackage[english]{babel}\englishtrue}
\RequirePackage[override]{xcolor}
\RequirePackage{url}
\RequirePackage{xspace}
\RequirePackage{verbatim}
\RequirePackage{comment}
\RequirePackage[draft,final]{pdfpages}
\ifloadams
\RequirePackage{amsmath,amssymb,amsthm}
\fi
\RequirePackage{mathrsfs}
% mismatches with Biblatex \RequirePackage{cite}
\RequirePackage{chngcntr}
\usepackage[multiple]{footmisc}
\renewcommand{\familydefault}{\sfdefault}
\RequirePackage[T1]{fontenc}
\RequirePackage[scaled=0.92]{helvet}
\RequirePackage{mathptmx}
\RequirePackage[table,figure]{settings/hsmw-counter}
\ifthenelse{\isundefined{\@englisch}}{%
\ifthenelse{\isundefined{\@norefpage}}{%
\RequirePackage[german,refpage]{nomencl}}{%
\RequirePackage[german,norefpage]{nomencl}}%
\RequirePackage[ngerman]{translator}
}{%
\ifthenelse{\isundefined{\@norefpage}}{%
\RequirePackage[english,refpage]{nomencl}}{%
\RequirePackage[english,norefpage]{nomencl}
}}
\ifthenelse{\isundefined{\@englisch}}{%
\RequirePackage[ngerman,german]{varioref}}{\RequirePackage[english]{varioref}}


% Einstellungen fuer Firmenlogo
\providecommand{\insertFirmenlogo}{}
\providecommand{\Firmenlogo}[1]{\renewcommand{\insertFirmenlogo}{#1}}

% Mathe-Fonts ohne Serifen
\ifthenelse{\isundefined{\@sansmath}}{}{%
\RequirePackage{sansmath}
\sansmath
}

% Zeilennummern im Draft-Modus
\ifdraft
\IfFileExists{lineno.sty}{%
\RequirePackage{lineno}
\pagewiselinenumbers
}{}
\fi

% Vermeidung von Zeilenumbruechen in Textfeldern
\providecommand{\keinUmbruch}[1]{%
\begingroup%
\renewcommand{\\}[1][]{}%
\renewcommand{\newline}{}%
#1%
\endgroup
}

% Felder
\ifenglish
\def\MNI{Applied Computer and Life Sciences}
\else
\def\MNI{Angewandte Computer- und Biowissenschaften}
\fi
\def\@Ort{Mittweida}
\ifenglish
\def\@Art{Master Thesis}
\else
\def\@Art{Bachelorarbeit}
\fi
\ifenglish
\def\@Anrede{Mr./Mrs.}
\else
\def\@Anrede{Herr/Frau}
\fi
\ifenglish
\def\@Vorname{Forename}
\def\@Nachname{Surname}
\else
\def\@Vorname{Vorname}
\def\@Nachname{Nachname}
\fi

\ifenglish
\def\@Thema{Topic \\ of \@Art}
\else
\def\@Thema{Thema \\ der \@Art}
\fi
\def\@Unterthema{}
\ifenglish
\def\@Studiengang{Your study programme}
\else
\def\@Studiengang{Studiengangsbezeichnung}
\fi
\ifenglish
\def\@Seminargruppe{Your seminar group}
\else
\def\@Seminargruppe{Gruppenbezeichnung}
\fi
\def\@Fakultaet{\MNI}
\def\@Erstpruefer{N.N.}
\def\@Zweitpruefer{N.N.}
\def\@WeitererBetreuer{N.N.} % Röbbe
\def\@BibliografischeAngaben{}
\def\@Anlagen{}
\def\@Tag{}
\def\@Monat{}
\def\@Jahr{\number\year}
\def\@Zusatz{}
\ifenglish
\def\@Satz{Typeset by \LaTeX{}}
\else
\def\@Satz{Satz: \,\LaTeX{}}
\fi
\def\@Verlag{}
\def\@Druck{}
\def\@ISBN{}
\def\@TitelZwei{} % Röbbe
\def\@WM{\textcolor{white}{HSMW-Thesis}}


% Kommandos zum Fuellen der Felder
\providecommand{\Ort}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Ort{#1}}}
\providecommand{\Art}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Art{#1}}}
\providecommand{\Anrede}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Anrede{#1}}}
\providecommand{\Vorname}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Vorname{#1}\author{\@Vorname{} \@Nachname}}}
\providecommand{\Nachname}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Nachname{#1}\author{\@Vorname{} \@Nachname}}}

%Röbbe
\ifmultiauthor
\providecommand{\Autorenteam}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Vorname{}\def\@Nachname{#1}\author{\@Autorenteam}}}
\else
\providecommand{\Autorenteam}[1]
\fi

\providecommand*{\Thema}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Thema{#1}\title{#1}}}
\providecommand*{\Unterthema}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Unterthema{#1}\subtitle{#1}}}
\providecommand{\Studiengang}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Studiengang{#1}}}
\providecommand{\Seminargruppe}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Seminargruppe{#1}}}
\providecommand{\Fakultaet}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Fakultaet{#1}}}
\providecommand{\Erstpruefer}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Erstpruefer{#1}}}
\providecommand{\Zweitpruefer}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Zweitpruefer{#1}}}
\providecommand{\WeitererBetreuer}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@WeitererBetreuer{#1}}} % Röbbe
\providecommand{\Anlagen}[1]{\def\@Anlagen{#1}}
\providecommand{\Tag}[1]{\def\@Tag{#1}}
\providecommand{\Monat}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Monat{#1}}}
\providecommand{\Jahr}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Jahr{#1}}}
\providecommand{\Copyright}[1]{\def\@Zusatz{#1}}
\providecommand{\Textsatz}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Satz{Satz: \,#1}\def\@texnote{true}}}
\providecommand{\Verlag}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Verlag{Verlag: \,#1}}}
\providecommand{\Druck}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@Druck{Druck: \,#1}}}
\providecommand{\ISBN}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@ISBN{ISBN: \,#1}}}
% Röbbe
\ifenglish
\providecommand{\TitelZwei}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@TitelZwei{German Title: \,\textit{#1}}}}
\else
\providecommand{\TitelZwei}[1]{\ifthenelse{\equal{#1}{\empty}}{}{\def\@TitelZwei{Englischer Titel: \,\textit{#1}}}}
\fi

% Aussehen der Anhaenge
\providecommand*{\appendixmore}{%
\renewcommand*{\chapterformat}{%
\appendixname~\thechapter:\enskip}
}

% Fussnoten, Tabellen und Abbildungen
\counterwithout{footnote}{chapter}
\ifthenelse{\isundefined{\@minussymbol}}{}{
\renewcommand\thefigure{\thechapter-\arabic{figure}}
\renewcommand\thetable{\thechapter-\arabic{table}}
}
\deffootnote{1em}{1em}{\textsuperscript{\thefootnotemark}\ }
\renewcommand*{\captionformat}{:~~}
\setkomafont{caption}{\small}
\setkomafont{captionlabel}{\small}

% Farben
\definecolor{HSMWcolor}{RGB}{47,106,174}
\colorlet{linkfarbe}[RGB]{HSMWcolor!75!black}

% Begriffe
\providecommand{\Erklaerungstext}{Erkl\"arung}
\providecommand{\listoffiguresandtablesname}{List of Figures and Tables}
\providecommand{\listoftablesandfiguresname}{List of Tables and Figures}
\providecommand{\tablesname}{Tables}
\providecommand{\figuresname}{Figures}
\ifthenelse{\isundefined{\@englisch}}{
% ROBBE \addto\captionsngerman{\renewcommand{\indexname}{Stichwortverzeichnis}}
\addto\captionsngerman{\renewcommand{\indexname}{Index}}
\addto\captionsngerman{\renewcommand{\listoffiguresandtablesname}{Abbildungs- und Tabellenverzeichnis}}
\addto\captionsngerman{\renewcommand{\listoftablesandfiguresname}{Tabellen- und Abbildungsverzeichnis}}
\addto\captionsngerman{\renewcommand{\tablesname}{Tabellen}}
\addto\captionsngerman{\renewcommand{\figuresname}{Abbildungen}}
\addto\captionsngerman{\renewcommand{\MNI}{Angewandte Computer- und Biowissenschaften}}
}{}

\ifloadams
\ifthenelse{\isundefined{\@englisch}}{\addto\captionsngerman{\renewcommand{\proofname}{Beweis}}}{}
\fi

% Einstellungen fuer Abkuerzungsverzeichnis
\setlength{\nomlabelwidth}{.20\hsize}
\renewcommand{\nomlabel}[1]{#1 \dotfill}
\setlength{\nomitemsep}{-2\parsep}

% Datum
\let\dateold\date
\renewcommand{\date}[1]{\dateold{#1}\AtBeginDocument{\ifthenelse{\equal{#1}{\empty}}{}{\renewcommand{\today}{#1}}}}
\providecommand{\Datum}[1]{\date{#1}}
\ifthenelse{\isundefined{\@englisch}}{}{\Datum{\textcolor{red}{Datum im Vorspann festlegen!}}}

% Einstellungen fuer Hyperref-Paket
\ifdraft\else
\ifthenelse{\isundefined{\@hypertext}}{%
\providecommand{\phantomsection}{}
}{%
\AtBeginDocument{\pagenumbering{alph}}
\Ifpdfoutput{%
\RequirePackage[pdftex,colorlinks,linkcolor=linkfarbe,urlcolor=linkfarbe,anchorcolor=linkfarbe,citecolor=linkfarbe,breaklinks,bookmarksnumbered]{hyperref}
}{%
\RequirePackage[dvips,colorlinks,linkcolor=linkfarbe,urlcolor=linkfarbe,anchorcolor=linkfarbe,citecolor=linkfarbe,bookmarksnumbered]{hyperref}
}{
\RequirePackage[figure,table]{hypcap}
}
\AtBeginDocument{%
\hypersetup%
{%
pdftitle = {\@Thema},
pdfsubject = {\@Art},
pdfauthor = {\@Vorname{} \@Nachname},
pdfcreator = {LaTeX mit HSMW-Thesis}
}}}
\fi


% Glossaries muss nach hyperref geladen werden!
\RequirePackage[toc,nonumberlist,translate=babel]{glossaries}
\renewcommand*{\GlossariesWarningNoLine}[1]{}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\AtBeginDocument{
% alles was hier kommt wird nach der Praeambel ausgefuehrt.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\title{\@Thema}
\subtitle{\@Unterthema}
\author{\@Vorname{} \@Nachname}

% Pakete showkeys einbinden
\ifdraft
\RequirePackage[notref,color]{showkeys}
\colorlet{labelkey}{HSMWcolor}
\fi

% Datum
\ifthenelse{\not\equal{\@Tag}{\empty} \and \not\equal{\@Monat}{\empty} \and \not\equal{\@Jahr}{\empty}}{\renewcommand{\today}{\@Tag. \@Monat{} \@Jahr}}{%
\ifthenelse{\not\equal{\@Monat}{\empty} \and \not\equal{\@Jahr}{\empty}}{\renewcommand{\today}{im \@Monat{} \@Jahr}}{}
}

% Theoreme, Definitionen usw.
\ifloadams
\ifthenelse{\isundefined{\Trennzeichen}}{\def\Trennzeichen{}}{}
\ifthenelse{\isundefined{\@thmbelow}}{%
\newtheoremstyle{plain}{5mm}{0mm}{\itshape}{}{\bfseries}{\Trennzeichen}{.6em}{}
\newtheoremstyle{definition}{5mm}{0mm}{\upshape}{}{\bfseries}{\Trennzeichen}{.6em}{}
\newtheoremstyle{remark}{5mm}{0mm}{\upshape}{}{\itshape}{\Trennzeichen}{.6em}{}
\newtheoremstyle{plain*}{5mm}{0mm}{\itshape}{}{\bfseries}{\Trennzeichen}{.6em}{}
\newtheoremstyle{definition*}{5mm}{0mm}{\upshape}{}{\bfseries}{\Trennzeichen}{.6em}{}
\newtheoremstyle{remark*}{5mm}{0mm}{\upshape}{}{\itshape}{\Trennzeichen}{.6em}{}
}{%
\newtheoremstyle{plain}{5mm}{0mm}{\itshape}{}{\bfseries}{\Trennzeichen}{\newline}{}
\newtheoremstyle{definition}{5mm}{0mm}{\upshape}{}{\bfseries}{\Trennzeichen}{\newline}{}
\newtheoremstyle{remark}{5mm}{0mm}{\upshape}{}{\itshape}{\Trennzeichen}{\newline}{}
\newtheoremstyle{plain*}{5mm}{0mm}{\itshape}{}{\bfseries}{\Trennzeichen}{\newline}{}
\newtheoremstyle{definition*}{5mm}{0mm}{\upshape}{}{\bfseries}{\Trennzeichen}{\newline}{}
\newtheoremstyle{remark*}{5mm}{0mm}{\upshape}{}{\itshape}{\Trennzeichen}{\newline}{}
}
\theoremstyle{plain}
\newtheorem{theorem}{Theorem}[chapter]
\newtheorem{hilfssatz}[theorem]{Hilfssatz}
\newtheorem{satz}[theorem]{Satz}
\newtheorem{korollar}[theorem]{Korollar}
\newtheorem{corollary}[theorem]{Corollary}
\newtheorem{folgerung}[theorem]{Folgerung}
\newtheorem{lemma}[theorem]{Lemma}
\theoremstyle{plain*}
\newtheorem*{theorem*}{Theorem}
\newtheorem*{hilfssatz*}{Hilfssatz}
\newtheorem*{satz*}{Satz}
\newtheorem*{korollar*}{Korollar}
\newtheorem*{corollary*}{Corollary}
\newtheorem*{folgerung*}{Folgerung}
\newtheorem*{lemma*}{Lemma}
\theoremstyle{definition}
\newtheorem{definition}[theorem]{Definition}
\newtheorem{beispiel}[theorem]{Beispiel}
\newtheorem{example}[theorem]{Example}
\newtheorem{festlegung}[theorem]{Festlegung}
\theoremstyle{definition*}
\newtheorem*{definition*}{Definition}
\newtheorem*{beispiel*}{Beispiel}
\newtheorem*{example*}{Example}
\newtheorem*{festlegung*}{Festlegung}
\theoremstyle{remark}
\newtheorem{bemerkung}[theorem]{Bemerkung}
\newtheorem{remark}[theorem]{Remark}
\theoremstyle{remark*}
\newtheorem*{bemerkung*}{Bemerkung}
\newtheorem*{remark*}{Remark}
\renewenvironment{proof}[1][\proofname]{\par
  \pushQED{\qed}%
  \normalfont \topsep-3.5\p@\@plus1\p@\relax
  \trivlist
  \item[\hskip\labelsep
        \itshape
    #1\@addpunct{:}]\ignorespaces
}{%
  \popQED\endtrivlist\@endpefalse
}
\let\beweis\proof
\let\endbeweis\endproof
\fi

\newcommand*{\@mymaketitle}{%
  \clearpage
  \let\footnote\thanks
  \ifx\@extratitle\@empty \else
    \noindent\@extratitle \next@tpage \if@twoside \null\next@tpage \fi
  \fi
  \setparsizes{\z@}{\z@}{\z@\@plus 1fil}\par@updaterelative
  \ifx\@titlehead\@empty \else
    \begin{minipage}[t]{\textwidth}
      \@titlehead
    \end{minipage}\par
  \fi
  \null
  \vskip 2em%
  \begin{center}%
    \ifx\@subject\@empty \else
      {\subject@font \@subject \par}
      \vskip 1.5em
    \fi
    {\titlefont\huge \@title Test \par}%
    \vskip .5em
    {\ifx\@subtitle\@empty\else\usekomafont{subtitle}\@subtitle\par\fi}%
    \vskip 1em
    {\Large
      \lineskip .5em%
      \begin{tabular}[t]{c}
        \@author
      \end{tabular}\par
    }%
    \vskip 1em%
    {\Large \@date \par}%
    \vskip \z@ \@plus 1em
    {\Large \@publishers \par}
    \ifx\@dedication\@empty \else
      \vskip 2em
      {\Large \@dedication \par}
    \fi
  \end{center}%
  \par
  \vskip 2em
}%

\ifmw@extratitle
\renewcommand{\maketitle}{\@mymaketitle}
\fi

% Aufruf von Makeindex
\IfFileExists{\jobname.idx}{\immediate\write18{makeindex \jobname.idx}}{}
\IfFileExists{\jobname.nlo}{%
\@ifpackageloaded{nomentbl}{%
\immediate\write18{makeindex \jobname.nlo -s nomentbl.ist -o \jobname.nls}
}{%
\immediate\write18{makeindex \jobname.nlo -s nomencl.ist -o \jobname.nls}
}%
}{}
\IfFileExists{\jobname.glo}{\immediate\write18{makeindex \jobname.glo -s \jobname.ist -t \jobname.glg -o \jobname.gls}}{}

% Pakete
% now in the kernel \RequirePackage{fixltx2e}
\RequirePackage{graphicx}
\RequirePackage{makeidx}
\RequirePackage{eso-pic}
\RequirePackage[headsepline]{scrlayer-scrpage}
\RequirePackage{setspace}

% Seitenstil
\pagestyle{scrheadings}
\clearscrheadfoot
\renewcommand*{\chapterpagestyle}{scrheadings}
\renewcommand*{\indexpagestyle}{scrheadings}
\renewcommand*{\partpagestyle}{scrheadings}
\providecommand{\mycleardoublepage}{\clearpage\ihead[]{}\cleardoublestandardpage}

% Groesse der Ueberschriften
\ifthenelse{\isundefined{\@bigheadings}}{}{%
\KOMAoption{headings}{big}
}

% Einstellungen
\setstretch{1.1}
\setkomafont{pageheadfoot}{\normalfont\sffamily}
\addtokomafont{pageheadfoot}{\linespread{1}\selectfont} 
\setkomafont{pagenumber}{\normalfont\sffamily}
\setheadsepline{0.5pt}

% Einstellungen und Definitionen fuer Kapitel- und Abschnittsueberschriften
\renewcommand*{\chapterheadstartvskip}{\vspace*{-\topskip}\vspace*{-0.8cm}}
\renewcommand*{\chapterheadendvskip}{\vspace{8mm}}
\renewcommand*{\othersectionlevelsformat}[1]{\makebox[1.35cm][l]{\csname the#1\endcsname\autodot}}
\renewcommand*{\chapterformat}{\makebox[1.35cm][l]{\thechapter\autodot}}
\renewcommand\section{\@startsection{section}{1}{\z@}%
  {-3mm \@plus -0.5ex \@minus -.2ex}%
  {0.5ex \@plus.1ex}%
  {\ifnum \scr@compatibility>\@nameuse{scr@v@2.96}\relax
    \setlength{\parfillskip}{\z@ plus 1fil}\fi
    \raggedsection\normalfont\sectfont\nobreak\size@section}%
}
\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
  {-3mm\@plus -0.5ex \@minus -.2ex}%
  {0.5ex \@plus .1ex}%
  {\ifnum \scr@compatibility>\@nameuse{scr@v@2.96}\relax
    \setlength{\parfillskip}{\z@ plus 1fil}\fi
    \raggedsection\normalfont\sectfont\nobreak\size@subsection
  }%
}
\renewcommand\subsubsection{\@startsection{subsubsection}{3}{\z@}%
  {-3mm\@plus -0.5ex \@minus -.2ex}%
  {0.5ex \@plus .1ex}%
  {\ifnum \scr@compatibility>\@nameuse{scr@v@2.96}\relax
    \setlength{\parfillskip}{\z@ plus 1fil}\fi
    \raggedsection\normalfont\sectfont\nobreak\size@subsubsection
  }%
}

% Einstellungen fuer Listen
\g@addto@macro\itemize{\setlength{\itemsep}{-0.48cm}}%
\g@addto@macro\enumerate{\setlength{\itemsep}{-0.48cm}}%
\g@addto@macro\description{\setlength{\itemsep}{-0.48cm}}%

% Einstellungen fuer Verzeichnisse
\addtocontents{lot}{\protect\doublespacing}
\addtocontents{lof}{\protect\doublespacing}
\addtocontents{nlo}{\protect\doublespacing}

% Einstellungen fuer Inhaltsverzeichnis
\ifthenelse{\isundefined{\@classictoc}}{%
\addtocontents{toc}{\protect\doublespacing}
\renewcommand{\@dotsep}{1}
\renewcommand\l@chapter{\@dottedtocline{0}{0em}{1.5em}}
\renewcommand\l@section{\@dottedtocline{1}{0em}{1.5em}}
\renewcommand*\l@subsection{\@dottedtocline{2}{1.5em}{2.3em}}
\renewcommand*\l@subsubsection{\@dottedtocline{3}{3.8}{3.2em}}
\renewcommand*\l@paragraph{\@dottedtocline{4}{7.0em}{4.1em}}
\renewcommand*\l@subparagraph{\@dottedtocline{5}{10em}{5em}}
\setkomafont{chapterentry}{\normalsize}
\setkomafont{chapterentrypagenumber}{\normalsize}
}{\KOMAoption{toc}{graduated}}

% Nummerierung der Verzeichnisse
\newcounter{myromancounter}
\setcounter{myromancounter}{0}
\ifthenelse{\isundefined{\@noromansectionnumbers}}{%
\def\myromanprefix{\addtocounter{myromancounter}{1}\Roman{myromancounter}.~~{}}
\providecommand{\myroman}{\Roman{myromancounter}}
}{\def\myromanprefix{\addtocounter{myromancounter}{1}}%
\providecommand{\myroman}{\Roman{myromancounter}}
}

% Makro fuer Vorspann
\renewcommand{\frontmatter}{%
\cleardoublepage
\pagestyle{scrheadings}
\clearscrheadfoot
\ifsmallromans
\pagenumbering{roman}
\setcounter{page}{\value{firstpage}}
\ohead[\pagemark]{\pagemark}
\renewcommand{\cleardoubleemptypage}{\mycleardoublepage}
\else
\ohead[]{\myroman}
\renewcommand{\thepage}{\Roman{myromancounter}}
\fi
}

% Makro fuer Hauptteil
\renewcommand{\mainmatter}{%
\cleardoublepage
\pagestyle{scrheadings}
\clearscrheadfoot
\ohead[\pagemark]{\pagemark}
\ifthenelse{\isundefined{\@arab}}{\def\@arab{true}\pagenumbering{arabic}}{\renewcommand{\thepage}{\arabic{page}}}
\renewcommand{\chaptermark}[1]{\ihead[\chaptername~\thechapter:\, ##1]{\chaptername~\thechapter:\, ##1}}
\renewcommand{\cleardoubleemptypage}{\mycleardoublepage}
\cleardoublepage
}

% Schmutztitel
\providecommand{\Schmutztitel}{%
\cleardoublepage
\thispagestyle{plain}
\parbox[s][\textheight]{92mm}{%
\begin{flushright}
\small
{\textcolor{black!80}{\ifenglish Faculty of \else Fakult\"at \fi} \textbf{\@Fakultaet}}\\
\rule{92mm}{0.75pt}\\[10pt]
\vspace{-0.5mm}
{\LARGE\textbf{\MakeUppercase{\@Art}}}\\[-2pt]
\vspace{-1mm}
\rule{92mm}{0.75pt}

\Large

\vspace{5.25cm minus 3.35cm}
\textbf{\@Thema}

\normalsize
{\ifx\@subtitle\@empty\else\vspace{2cm minus 1.5cm}\textbf{\@subtitle}\par\fi}%
\small
\vspace{3.6cm minus 1.7cm}
\ifmultiauthor %Röbbe
\ifenglish Authors\else Autoren\ifthenelse{\equal{\@Anrede}{Frau}}{in}{}\fi:\\
\else
\ifenglish Author\else Autor\ifthenelse{\equal{\@Anrede}{Frau}}{in}{}\fi:\\
\fi
\textbf{\@Vorname{} \@Nachname}

\vskip3.5ex
\vspace{-1mm}
\ifenglish Study Programme\else Studiengang\fi:\\
\@Studiengang

\vskip3.5ex
\vspace{-1mm}
\ifenglish Seminar Group\else Seminargruppe\fi:\\
\@Seminargruppe

\vskip3.5ex
\vspace{-1mm}
\ifenglish First Referee\else Erstpr\"ufer\fi:\\
\@Erstpruefer

\vskip3.5ex
\vspace{-1mm}
\ifenglish Second Referee\else Zweitpr\"ufer\fi:\\
\@Zweitpruefer

%Röbbe
\vskip3.5ex
\vspace{-1mm}
\ifenglish Additional Supervisor\else Weiterer Betreuer\fi:\\
\@Zweitpruefer

\vskip10ex
\vspace{-2mm}
Mittweida, \@Monat{} \@Jahr
\end{flushright}
}
}

% Titelseite
\renewcommand{\maketitle}{%
\begin{titlepage}
\AddToShipoutPicture*{%
\insertFirmenlogo%
\Ifpdfoutput{
\ifjubilogo
\put(369,731){\includegraphics[width=56mm, viewport = 0 0 215 122,
    clip]{settings/hsmw-logo-150}}
\else
%\put(373,745){\includegraphics[width=56mm, viewport = 5 6 280 131,
\put(373,745){\includegraphics[width=70mm, viewport = 0 0 280 131,
    clip]{settings/hsmw-logo}}
\fi
}%
{
\ifjubilogo
\put(368,730){\includegraphics[width=55.5mm]{settings/hsmw-logo-150.ps}}
\else
\put(372,744){\includegraphics[width=55.5mm]{settings/hsmw-logo.ps}}
\fi
}
}
~\\ 
\vfill
\parbox[s][183mm]{92mm}{%
\begin{raggedleft}
\rule{92mm}{0.75pt}\\[4mm]
\Huge \textbf{\MakeUppercase{\@Art}}\\[-2mm]
\rule{92mm}{0.75pt}

\vspace{3cm}
\small
~\@Anrede\\
\textbf{\@Vorname{} \@Nachname}

\vspace{1.5cm}
\Large
\textbf{\@Thema}

\normalsize
{\ifx\@subtitle\@empty\else\vspace{1cm minus
    0.5cm}\textbf{\@subtitle}\par\vskip 2em\fi}%
\vspace{0.8cm}
\small
\hfill\@Jahr
\end{raggedleft}
}
\end{titlepage}
\Schmutztitel
}

\ifdraft\else
\AtBeginDocument{\maketitle}
\fi

% Verzeichnisse 
\providecommand{\figuresandtables}{%
\ifthenelse{\not\boolean{seplists}}{\listoffiguresandtables}{\listoffigures\listoftables}
}
\providecommand{\tablesandfigures}{%
\ifthenelse{\not\boolean{seplists}}{\listoftablesandfigures}{\listoftables\listoffigures}
}
\providecommand{\printfiguresandtables}{\ifthenelse{\isundefined{\tablesfirst}}{\figuresandtables}{\tablesandfigures}}
\providecommand{\Verzeichnisse}{%
\tableofcontents
\printfiguresandtables
\printnomenclature
}

% Bibliografische Angaben und Referat
\providecommand{\@comma}[1]{\ifthenelse{\equal{#1}{\empty}}{}{#1,\xspace}}
\providecommand{\@colon}[1]{\ifthenelse{\equal{#1}{\empty}}{}{#1:}}
\providecommand{\Hochschule}{Hochschule Mittweida, University of Applied Sciences}
\providecommand{\@adjustcounters}{%
\ifthenelse{\equal{\totalfigures}{0}}{\providecommand{\nofigures}{}}{\ifthenelse{\equal{\totalfigures}{1}}{\providecommand{\nofigures}{1~\ifenglish
      figure\else Abbildung\fi}}{\providecommand{\nofigures}{\totalfigures{}~\ifenglish
      figures\else Abbildungen\fi}}}
\ifthenelse{\equal{\totaltables}{0}}{\providecommand{\@notables}{}}{\ifthenelse{\equal{\totaltables}{1}}{\providecommand{\@notables}{1~\ifenglish
      table\else
      Tabelle\fi}}{\providecommand{\@notables}{\totaltables{}~\ifenglish
      tables\else Tabellen\fi}}}
\ifthenelse{\isundefined{\counttables}}{\providecommand{\notables}{}}{\providecommand{\notables}{\@notables}}
}
\providecommand{\LetzteSeite}{\pageref{verylastpage}}
\providecommand{\sLetzteSeite}{\pageref*{verylastpage}}
\providecommand{\BibAngaben}{%
\@adjustcounters

% Röbbe
\ifmultiauthor
{\@Nachname}\@colon\
\else
\@comma{\@Nachname}\@colon{\@Vorname}\
\fi
\,\keinUmbruch{\@comma{\@Thema}}\keinUmbruch{\@comma{\@subtitle}}\ifthenelse{\isundefined{\@hypertext}}{\@comma{\LetzteSeite~\ifenglish
    pages\else Seiten\fi}}{\@comma{\sLetzteSeite~\ifenglish pages\else Seiten\fi}}\@comma{\nofigures}\@comma{\notables}\@comma{\@Anlagen}\@comma{\Hochschule}\ifenglish
Faculty of \else Fakult\"at \fi\@Fakultaet
}
\ifthenelse{\isundefined{\@texnote}}{\def\@texnote{false}}{}

\ifdraft
\renewcommand{\frontmatter}{}
\fi

\newenvironment{Kurzbeschreibung}{% Röbbe
\small
\pagestyle{scrheadings}
\clearscrheadfoot
\cleardoublepage
\minisec{\ifenglish Bibliographic Information\else Bibliografische Angaben\fi}
\BibAngaben
\par
\ifthenelse{\equal{\@TitelZwei}{\empty}}{}{\par\@TitelZwei}
\par
{
\parindent0em
\@comma{\@Art} \@Jahr
\ifthenelse{\equal{\@Zusatz}{\empty}}{}{\par\@Zusatz}
\ifthenelse{\boolean{\@texnote} \or \not\equal{\@Verlag}{\empty} \or \not\equal{\@Druck}{\empty}}{\par \ifthenelse{\equal{\@Satz}{\empty}}{}{\@Satz\\} \ifthenelse{\equal{\@Verlag}{\empty}}{}{\@Verlag\\} \@Druck}{}
\ifthenelse{\equal{\@ISBN}{\empty}}{}{\par\@ISBN}
}
\vfill
\minisec{\ifenglish Abstract \else Kurzbeschreibung \fi}
}{%
\frontmatter
\Verzeichnisse
}

% Inhaltsverzeichnis - Tiefe auf vier gesetzt
\setcounter{tocdepth}{4}
\let\tableofcontentsold\tableofcontents
\renewcommand{\tableofcontents}{%
\cleardoublepage
\pagestyle{scrheadings}
\let\contentsnameold\contentsname
\renewcommand{\contentsname}{\myromanprefix\contentsnameold}
\phantomsection
\addcontentsline{toc}{chapter}{\contentsnameold}
\tableofcontentsold
\cleardoublepage
}

% Separates Abbildungsverzeichnis
\let\listoffiguresold\listoffigures
\ifnofigures
\renewcommand{\listoffigures}{}
\else
\renewcommand{\listoffigures}{%
\cleardoublepage
\pagestyle{scrheadings}
\let\listfigurenameold\listfigurename
\renewcommand{\listfigurename}{\myromanprefix\listfigurenameold}
\phantomsection
\addcontentsline{toc}{chapter}{\listfigurenameold}
\listoffiguresold
\cleardoublepage
}
\fi

% Separates Tabellenverzeichnis
\let\listoftablesold\listoftables
\ifnotables
\renewcommand{\listoftables}{}
\else
\renewcommand{\listoftables}{%
\cleardoublepage
\pagestyle{scrheadings}
\let\listtablenameold\listtablename
\renewcommand{\listtablename}{\myromanprefix\listtablenameold}
\phantomsection
\addcontentsline{toc}{chapter}{\listtablenameold}
\listoftablesold
\cleardoublepage
}
\fi

% Gemeinsames Abbildungs- und Tabellenverzeichnis 
\providecommand{\listoffiguresandtables}{%
\cleardoublepage
\pagestyle{scrheadings}
\chapter*{\myromanprefix\listoffiguresandtablesname}
\addcontentsline{toc}{chapter}{\listoffiguresandtablesname}
\begingroup
\KOMAoption{listof}{leveldown}
\renewcommand{\listtablename}{\large\tablesname}
\renewcommand{\listfigurename}{\large\figuresname}
\listoffiguresold
\listoftablesold
\endgroup
\cleardoublepage
}

% Gemeinsames Tabellen- und Abbildungsverzeichnis
\providecommand{\listoftablesandfigures}{%
\cleardoublepage
\pagestyle{scrheadings}
\chapter*{\myromanprefix\listoftablesandfiguresname}
\addcontentsline{toc}{chapter}{\listoftablesandfiguresname}
\begingroup
\KOMAoption{listof}{leveldown}
\renewcommand{\listtablename}{\large\tablesname}
\renewcommand{\listfigurename}{\large\figuresname}
\listoftablesold
\listoffiguresold
\endgroup
\cleardoublepage
}

% Abkuerzungsverzeichnis
\let\printnomenclatureold\printnomenclature
\ifnonomenclature
\renewcommand{\printnomenclature}{}
\else
\renewcommand{\printnomenclature}{%

\let\nomnameold\nomname
\renewcommand{\nomname}{\myromanprefix\nomnameold}
\phantomsection
\addcontentsline{toc}{chapter}{\nomnameold}

\ifsmallromans


\ohead[\pagemark]{\pagemark}
\renewcommand{\cleardoubleemptypage}{\mycleardoublepage}
\printnomenclatureold
\cleardoublepage

\else
\cleardoublepage
\pagestyle{scrheadings}
\cleardoublepage
\printnomenclatureold
\ohead[]{\myroman}
\cleardoublepage
\fi
}
\fi

%Danksagung / Röbbe
\newenvironment{Danksagung}{%
\cleardoublepage
\pagestyle{scrheadings}
\let\prefacenameold\prefacename
%\renewcommand{\prefacename}{\myromanprefix\prefacenameold}
\ifenglish
\newcommand{\thanx}{Acknowledgement}
\else
\newcommand{\thanx}{Danksagung}
\fi

\chapter*{\myromanprefix\thanx}
\ifsmallromans
\addcontentsline{toc}{chapter}{\thanx}
\ohead[\pagemark]{\pagemark}
\renewcommand{\cleardoubleemptypage}{\mycleardoublepage}
\else
\renewcommand{\thepage}{\Roman{myromancounter}}
\addcontentsline{toc}{chapter}{\thanx}
\ohead[]{\myroman}
\fi}{\mainmatter}


% Vorwort
\newenvironment{Vorwort}{%
\cleardoublepage
\pagestyle{scrheadings}
\let\prefacenameold\prefacename
\renewcommand{\prefacename}{\myromanprefix\prefacenameold}
\chapter*{\prefacename}
\ifsmallromans
\addcontentsline{toc}{chapter}{\prefacenameold}
\ohead[\pagemark]{\pagemark}
\renewcommand{\cleardoubleemptypage}{\mycleardoublepage}
\else
\renewcommand{\thepage}{\Roman{myromancounter}}
\addcontentsline{toc}{chapter}{\prefacenameold}
\ohead[]{\myroman}
\fi}{\mainmatter}

% Anhang
\let\appendixold\appendix
\renewcommand{\appendix}{%
\mainmatter
\renewcommand{\chapterformat}{\appendixname{} \thechapter}
\renewcommand{\chaptername}{\appendixname}
\appendixold
}

\providecommand{\backmatter}{\appendix}
\providecommand{\Anhang}{\appendix}
\providecommand{\Hauptteil}{\mainmatter}

% Literaturverzeichnis
\let\@ldthebibliography\thebibliography
\renewcommand{\thebibliography}[1]{%
\mycleardoublepage
\ihead[\bibname]{\bibname}
\renewcommand{\cleardoubleemptypage}{}
\@ldthebibliography{#1}
\renewcommand{\cleardoubleemptypage}{\mycleardoublepage}
}
\let\@ldendthebibliography\endthebibliography
\renewcommand{\endthebibliography}{%
\ifdraft\clearpage\else\mycleardoublepage\fi
}


% Stichwortverzeichnis
\let\printindexold\printindex
\ifnoindex
\renewcommand{\printindex}{}
\else
\renewcommand{\printindex}{%
\mycleardoublepage
\ihead[\indexname]{\indexname}
\renewcommand{\cleardoubleemptypage}{}
\begingroup
\renewcommand*{\chapterheadstartvskip}{\vspace*{-\topskip}\vspace{1.7mm}}
\renewcommand*{\chapterheadendvskip}{\vspace{9mm}}
\printindexold
\endgroup
\renewcommand{\cleardoubleemptypage}{\mycleardoublepage}
\mycleardoublepage
}
\fi

% Glossaries

\let\printglossariesold\printglossaries
\ifnoglossary
\renewcommand{\printglossaries}{}
\else
\renewcommand{\printglossaries}{%
\mycleardoublepage
\ihead[\glossaryname]{\glossaryname}
\renewcommand{\cleardoubleemptypage}{}
\begingroup
\renewcommand*{\chapterheadstartvskip}{\vspace*{-\topskip}\vspace{1.7mm}}
\renewcommand*{\chapterheadendvskip}{\vspace{9mm}}
\printglossariesold
\endgroup
\renewcommand{\cleardoubleemptypage}{\mycleardoublepage}
\mycleardoublepage
}
\fi

% Selbststaendigkeitserklaerung
\def\Erklaerungstext{%
\label{verylastpage}
\parindent0em
\ifEid 
\ifmultiauthor % Röbbe
Hiermit versicheren wir an Eides statt, dass wir diese Arbeit selbstst\"andig verfasst, keine anderen als die angegebenen Quellen und Hilfsmittel benutzt und die Arbeit noch nicht anderweitig f\"ur Pr\"ufungszwecke vorgelegt haben.
\else
Hiermit versichere ich an Eides statt, dass ich meine Arbeit selbstst\"andig verfasst, keine anderen als die angegebenen Quellen und Hilfsmittel benutzt und die Arbeit noch nicht anderweitig f\"ur Pr\"ufungszwecke vorgelegt habe.
\fi

\par
Stellen, die w\"ortlich oder sinngem\"a\ss{} aus Quellen entnommen wurden, sind als solche kenntlich gemacht.
\else
\ifmultiauthor %Röbbe
Hiermit erkl\"aren wir, dass wir diese Arbeit selbstst\"andig verfasst, keine anderen als die angegebenen Quellen und Hilfsmittel benutzt und die Arbeit noch nicht anderweitig f\"ur Pr\"ufungszwecke vorgelegt haben.
\else
Hiermit erkl\"are ich, dass ich meine Arbeit selbstst\"andig verfasst, keine anderen als die angegebenen Quellen und Hilfsmittel benutzt und die Arbeit noch nicht anderweitig f\"ur Pr\"ufungszwecke vorgelegt habe.
\fi

\par
Stellen, die w\"ortlich oder sinngem\"a\ss{} aus Quellen entnommen wurden, sind als solche kenntlich gemacht.
\fi
}
\providecommand{\Erklaerung}{%
\mycleardoublepage
\ifEid
\addchap*{Eidesstattliche Versicherung}
\ihead[Eidesstattliche Versicherung]{Eidesstattliche Versicherung}
\else
\addchap*{Erkl\"arung}
\ihead[Erkl\"arung]{Erkl\"arung}
\fi
\Erklaerungstext
\par\vspace{2cm}
\noindent\@Ort, \today
\vfill
\@WM
\clearpage
}

\ifdraft
\providecommand{\frontmatter}{}
\excludecomment{Kurzbeschreibung} % Röbbe
\excludecomment{Vorwort}
%\excludecomment{Danksagung} %Röbbe
\renewcommand{\Verzeichnisse}{}
\renewcommand{\Erklaerung}{}%
\renewcommand{\printindex}{}%
\renewcommand{\makeindex}{}%
\renewcommand{\printglossaries}{}%
\renewcommand{\makeglossaries}{}%
\renewcommand{\makenomenclature}{}%
\AtBeginDocument{\mainmatter}
\fi


\ifthenelse{\isundefined{\@englisch}}{
\renewcommand{\nomname}{Abk\"urzungsverzeichnis}
\addto\captionsngerman{\renewcommand{\nomname}{Abk\"urzungsverzeichnis}}{}}

\makeindex
\makenomenclature
\makeglossaries
\AtEndDocument{\printindex\printglossaries\Erklaerung}

% Anpassung an KOMAScript Version 3.15+
\renewcommand{\chapterheadstartvskip}{\vspace{-1.7mm}}

% href in schwarz, falls ohne Option hypertext
\@ifpackageloaded{hyperref}{}{\providecommand{\href}[2]{#2}}

} % \AtBeginDocument

\endinput
