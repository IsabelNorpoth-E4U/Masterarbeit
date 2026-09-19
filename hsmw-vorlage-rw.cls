\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{hsmw-vorlage-rw}[2025/05/03 Corporate Design  Vorlage der Hochschule Mittweida] 
% Based on: https://git.hs-mittweida.de/hsmw-latex/hsmw-latex


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Preliminar Packages and Programming Interfaces

\def\currentClassName{hsmw-vorlage-rw}

\RequirePackage[l2tabu, orthodox]{nag} % Informs about obsolete package or command use (l2tabu) and syntactic correct, but semantic may incorrect code (orthodox): Best to load as first package
\RequirePackage{xkeyval} % Option Processing
\RequirePackage{etoolbox} % Latex Programming Interface and Toggles
\RequirePackage{iftex} % Provides compiler tests (pdfLaTeX, XeLaTeX, LuaLaTeX)
\RequirePackage{pgffor} % Simple Loop-Support (\foreach), \breakforeach

\NewDocumentCommand{\@mapping}{mmm}{\foreach \name in {#3}{\expandafter\gdef\csname mapping@#1@value@\name \endcsname{#2}}}
\NewDocumentCommand{\@mapping@value}{mm}{\ifcsdef{mapping@#1@value@#2}{\csname mapping@#1@value@#2\endcsname}{10000}}

% Internal command to print warnings to document and log file
\NewDocumentCommand{\PrintWarning}{ssoms}% writeToDocument*, ignoreLogfile**, [document text], text, raise error on log* | logonly,logandwrite,writeonly (trailing star to convert warning to error, if it should be logged)
{%
	\IfBooleanT{#1}
	{%
		\IfNoValueTF{#3}
		{\textcolor{red}{#4}}
		{\textcolor{red}{#3}}%
	}%
	\IfBooleanF{#2}
	{%
		\IfBooleanTF{#5}
		{%
			\ClassError{\currentClassName}{#4}{}%
		}{%
			\ClassWarningNoLine{\currentClassName}{#4}%
		}%
	}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Options

% Language: Load default language of the document (default: ngerman)
\DeclareOptionX{language}[ngerman]%
{
	% Introduce switch to transform "german" to "ngerman" (if for any reason it is specified)
	\def\selectedLanguage{#1}
	\ifdefstring{\selectedLanguage}{german}{\def\selectedLanguage{ngerman}}{}

	\PassOptionsToPackage{\selectedLanguage}{babel}
	\PassOptionsToPackage{\selectedLanguage}{cleveref}
	\PassOptionsToPackage{\selectedLanguage}{datetime2}
}


% Layout: Enable draft mode
\newtoggle{option@layout@draft}
\DeclareOptionX{draft}%
{
	\settoggle{option@layout@draft}{true}
	\ExecuteOptionsX{noautobuild}
	\PassOptionsToClass{draft}{scrbook}
}

% Layout: Place list of figures and list of tables together on a single page
\newtoggle{option@layout@listof@compact}
\DeclareOptionX{compactlistof}{\settoggle{option@layout@listof@compact}{true}}

% Layout: Place list of tables before list of figures
\newtoggle{option@layout@listof@tablesfirst}
\DeclareOptionX{lotbeforelof}{\settoggle{option@layout@listof@tablesfirst}{true}}

% Layout: Place glossary behind the other lists after toc instead at the end of the document (default: false)
\newtoggle{option@layout@glossary@front}
\DeclareOptionX{glossaryfront}[true]{\settoggle{option@layout@glossary@front}{#1}}

% Layout: Hides the statement of authorship
\newtoggle{option@layout@authorship@show}\settoggle{option@layout@authorship@show}{true}
\DeclareOptionX{noauthorship}{\settoggle{option@layout@authorship@show}{false}}


% Layout: Switch to onesided layout (true, false)
\newtoggle{option@layout@onesided}
\DeclareOptionX{onesided}[true]{\settoggle{option@layout@onesided}{#1}}

% Layout: Disables the second title page (english)
\newtoggle{option@layout@secondtitle}\settoggle{option@layout@secondtitle}{true}
\DeclareOptionX{nosecondtitle}{\settoggle{option@layout@secondtitle}{false}}

% Layout: Modifies the predefined colors to cmyk and sets colorlinks=false (needs to be used prior to option colorlinks)
\newtoggle{option@layout@printmode}
\DeclareOptionX{printmode}
{
	\settoggle{option@layout@printmode}{true}
	\ExecuteOptionsX{colorlinks=false}
	\PassOptionsToPackage{cmyk}{xcolor}
}

% Layout: Sets the type of thesis and adjusts names, styles and the layout (needs to be used prior to option onesided): paper, diploma, bachelor*, master
\@mapping{thesis}{0}{paper,termpaper,report,beleg}
\@mapping{thesis}{1}{shortpaper,shorttermpaper,shortreport,kurzbeleg}
\@mapping{thesis}{2}{diploma,dipl,diplom}
\@mapping{thesis}{3}{bachelor,ba}
\@mapping{thesis}{4}{master,ma}
%RÖBBE
\@mapping{thesis}{5}{protokoll}
\newcommand{\option@preset@thesis@name}{\PrintWarning*[THESIS TYPE]{Bitte Art der Arbeit angeben}}
\newtoggle{option@layout@paper}% Switches between thesis and paper layout
\newtoggle{option@layout@shortpaper}
\DeclareOptionX{thesis}[bachelor]%
{
	\ifcase\@mapping@value{thesis}{#1}
		% Termpaper
		\renewcommand{\option@preset@thesis@name}{\GetMultiLanguageLabel{thesis@name@paper}}
		\settoggle{option@layout@paper}{true}
		\ExecuteOptionsX{onesided}
	\or	% Short Termpaper (do the same as with regular paper and additionally remove newlines before chapter)
		\renewcommand{\option@preset@thesis@name}{\GetMultiLanguageLabel{thesis@name@paper}}
		\settoggle{option@layout@paper}{true}
		\ExecuteOptionsX{onesided}
		\settoggle{option@layout@shortpaper}{true}
		\ExecuteOptionsX{captionstyle=flat}
		\ExecuteOptionsX{compactlistof}
	\or % Diploma
		\renewcommand{\option@preset@thesis@name}{\GetMultiLanguageLabel{thesis@name@diploma}}
	\or % Bachelor
		\renewcommand{\option@preset@thesis@name}{\GetMultiLanguageLabel{thesis@name@bachelor}}
	\or % Master
		\renewcommand{\option@preset@thesis@name}{\GetMultiLanguageLabel{thesis@name@master}}
    %RÖBBE
	\or % Protokoll
		\renewcommand{\option@preset@thesis@name}
        {\GetMultiLanguageLabel{thesis@name@protokoll}}
        \settoggle{option@layout@paper}{true}
	\else
		\renewcommand{\option@preset@thesis@name}{\PrintWarning*[THESIS TYPE]{The specified thesis type '#1' is unknown}}
	\fi	
}


% Style: Use a graduated toc instead of a flat one
\newtoggle{option@style@toc@graduated}
\DeclareOptionX{graduatedtoc}{\settoggle{option@style@toc@graduated}{true}}

% Style: Sets the type of caption handling
\newtoggle{option@style@caption@label@minus} % Use a minus as caption label delimiter ("Figure 1-2:" instead of "Figure 1.2:")
\newtoggle{option@style@caption@label@nochapter} % Do not reset counter on new chapter and therefore count continuously
\@mapping{captionstyle}{0}{,.,d,dot,default}
\@mapping{captionstyle}{1}{-,m,minus}
\@mapping{captionstyle}{2}{*,f,flat,nochapter}
\DeclareOptionX{captionstyle}[dot]%
{
	\ifcase\@mapping@value{captionstyle}{#1}
		% Default
		\settoggle{option@style@caption@label@minus}{false}
		\settoggle{option@style@caption@label@nochapter}{false}
	\or	% Minus
		\settoggle{option@style@caption@label@minus}{true}
		\settoggle{option@style@caption@label@nochapter}{false}
	\or % Flat
		\settoggle{option@style@caption@label@minus}{false}
		\settoggle{option@style@caption@label@nochapter}{true}
	\else
		\PrintWarning{The specified captionstyle '#1' is unknown and will be ignored}
	\fi
}
\DeclareOptionX{minuscaption}{\PrintWarning{The class option minuscaption is deprecated. Please use captionstyle=minus instead}*}

% Style: Use lowercase roman page numers for the frontmatter (default: uppercase roman page numbers)
\newtoggle{option@style@frontmatter@pagenumber@smallromans}
\DeclareOptionX{smallromans}{\settoggle{option@style@frontmatter@pagenumber@smallromans}{true}}

% Style: Adjust multiple style options (use inofficial adaptions to match the unreleased corporate design 2019)
\newtoggle{option@style@fancy}
\DeclareOptionX{fancy}{\settoggle{option@style@fancy}{true}} 

% Style: Switches colored links in the document (default=true)
\newtoggle{option@style@colorlinks}
\DeclareOptionX{colorlinks}[true]{\settoggle{option@style@colorlinks}{#1}}

% Style: Switches acronym links (default=true)
\newtoggle{option@style@acronym@href}\settoggle{option@style@acronym@href}{true}
\DeclareOptionX{acronymhref}[true]{\settoggle{option@style@acronym@href}{#1}}

% Style: Switches acronym dots (default=true)
\newtoggle{option@style@acronym@dots}\settoggle{option@style@acronym@dots}{true}
\DeclareOptionX{acronymdots}[true]{\settoggle{option@style@acronym@dots}{#1}}

% Style: Switches symbols links (default=true)
\newtoggle{option@style@symbols@href}\settoggle{option@style@symbols@href}{true}
\DeclareOptionX{symbolshref}[true]{\settoggle{option@style@symbols@href}{#1}}

% Style: Switches symbols dots (default=true)
\newtoggle{option@style@symbols@dots}\settoggle{option@style@symbols@dots}{true}
\DeclareOptionX{symbolsdots}[true]{\settoggle{option@style@symbols@dots}{#1}}

% Style: Switches glossary links (default=true)
\newtoggle{option@style@glossary@href}\settoggle{option@style@glossary@href}{true}
\DeclareOptionX{glossaryhref}[true]{\settoggle{option@style@glossary@href}{#1}}


% Math: Use a linebreak after theorem (instead of a small horizontal skip)
\newtoggle{option@math@theorem@below}
\DeclareOptionX{theorembelow}{\settoggle{option@math@theorem@below}{true}}

% Math: Specify the separater between theorem label and content (e.g. ".", ":", "-"), default=<none>
\newcommand{\option@math@theorem@delimiter}{}
\DeclareOptionX{theoremdelim}[]{\renewcommand{\option@math@theorem@delimiter}{#1}}

% Math: Enable sans serif math fonts
\newtoggle{option@math@font@sansserif}
\DeclareOptionX{sansmath}{\settoggle{option@math@font@sansserif}{true}} 


% Preset: Sets a default faculty name (inw, cb, wi, sw, me): no need to call \faculty in preamble
\newcommand{\option@preset@faculty@name}{}
\DeclareOptionX{faculty}[]%
{
	\renewcommand{\option@preset@faculty@name}{\IfMultiLanguageLabel{faculty@name@#1}{\GetMultiLanguageLabel{faculty@name@#1}}{\PrintWarning*[FACULTY NAME]{The specified faculty type '#1' is unknown}}}
}

% Processing: Disables automatic building (makeindex) of glossary, acronyms and index (current auxiliaries are still used)
\DeclareOptionX{noautobuild}[true]%
{
	\ifstrequal{#1}{false}
	{% Autobuild
		\PassOptionsToPackage{automake}{glossaries}
	}{% No Autobuild
		\PassOptionsToPackage{noautomatic}{imakeidx}
		\PassOptionsToPackage{automake=false}{glossaries}
	}
}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Option Defaults and Processing

% Pass all not processed options to class
\DeclareOptionX*{\PassOptionsToClass{\CurrentOption}{scrbook}}

% Set default options to be loaded 
\ExecuteOptionsX{language=ngerman}
\ExecuteOptionsX{colorlinks=true}
\ExecuteOptionsX{thesis=bachelor}
\ExecuteOptionsX{noautobuild=false}
\ExecuteOptionsX{captionstyle=dot}

% Process all options
\ProcessOptionsX*\relax

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Base Class

\LoadClass{scrbook}
\RequirePackage{scrhack} % Hacks some known issues with other packages to be more compatible with KOMA (needed e.g. to process listings in toc)

%\KOMAoption{DIV}{10} % DIV=10: 11pt, width 147 height 207.90 margintop 29.70 margininner 21.00
\KOMAoption{parskip}{full-} % Change distance between paragraphs to full lines (no, full, half): no need to manually modify \parskip and \parindent
\KOMAoption{numbers}{noenddot} % Dots behind outline numbers of chapters/sections etc.: auto (Duden: sometimes a dot, depending on \arabic, \roman, etc.), enddot (always a dot), noenddot (never a dot)

% Switch between onesided or twosided layout
\iftoggle{option@layout@onesided}{\KOMAoption{twoside}{false}}{\KOMAoption{twoside}{true}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Unused default scrbook fields

%\extratitle{Schmutztitel} 
%\titlehead{Kopfzeile Titelseite}
%\subject{Art der Arbeit}
%\publishers{Verlag}
%\uppertitleback{Titelrückseitenkopf}
%\lowertitleback{Titelrückseitenfuß}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Packages

\iftoggle{option@layout@draft}
{
	% Add line numbers in draft
	\IfFileExists{lineno.sty}{\RequirePackage{lineno}\pagewiselinenumbers}{}
	
	% Shows label names in the margin area
	\IfFileExists{showkeys.sty}{\RequirePackage{xcolor}\RequirePackage[color]{showkeys}}{}
	
	% Draw geometry borders
	\PassOptionsToPackage{showframe}{geometry}
	
	% Remove scrlayer rulers (annoying)
	\PassOptionsToPackage{draft=false}{scrlayer-scrpage}
}{
	% Switching from draft to nondraft causes errors in aux due to missing macro from "lineno"
	\providecommand{\@LN}[2]{}
}

%%% Encodings
% Pass specific options to the font package depending on the used compiler (pdfLaTeX, XeLaTeX, LuaLaTeX)
\iftutex% True for XeTeX (\ifxetex) and LuaTeX (ifluatex)
\else% Probably PDFTeX
\RequirePackage[T1]{fontenc} % Font-Encoding
\RequirePackage[utf8]{inputenc} % Input-Encoding
\fi

%%% Font and Font Improvements
\iftoggle{option@style@fancy}
{
	% Use Bera Type 1 fonts (Bitstream Vera family) for serif and typewriter (looks as a good match to Open Sans)
	\RequirePackage[scaled]{beraserif} % use as \rmdefault
	\RequirePackage[scaled]{beramono} % use as \ttdefault
	% Load OpenSans as sansserif and normalfont
	\RequirePackage[default,defaultsans,scale=0.95]{opensans} % Sets OpenSans as familydefault and sfdefault, use proportional numbers
}{
	\RequirePackage{lmodern} % Fallback font: latin modern (less pixelated)
	% Load Helvetica (Arial) as sansserif and normalfont
	\RequirePackage[scaled=0.92]{helvet} % Helvetica (Scaled for best viewing experience): Closest font for arial (which is not shipped with standard latex distributions)
	\renewcommand{\familydefault}{\sfdefault}
	%TODO: LuaLaTeX and XeLaTeX seem to have problems here...
}
\RequirePackage[
%	protrusion=true,			% activate protrusion (default: true)
%	expansion=nocompatibility	% activate expansion (default: true)
%	auto=true					% activates font expansion (default: true)
%	tracking=true,				% activate tracking (default: false)
%	kerning=true,				% activate kerning (default: false)
%	spacing=true,				% activate spacing (default: false)
factor=1100,				% factor=1100 - add 10% to the protrusion amount (default: 1000)
stretch=10,					% stretch=10, shrink=10 - reduce stretchability/shrinkability (default is 20/20)
shrink=10,
%	
babel=true,					% Typesetting according to selected language (default: false)
]{microtype} % This command basically improves typesetting of a document (spacing between words: fewer hyphens and overfull hboxes)
\RequirePackage[defaultlines=3, all]{nowidow} % Prevent widows

%%% Page layout
%TODO: Page boundaries and borders: see DIV and BCOR options as well as typearea in scrguide (page layout by proportions instead of hard numbers)... possibly clashes with corporate design requirements
\RequirePackage[paper=a4paper]{geometry} % Modifies page layout (inner=left=binding)
\RequirePackage[headsepline=0.5pt]{scrlayer-scrpage} % Head and footer

%%% Language, Hyphenation and Text Improvements
\RequirePackage{babel} % Load babel package for language support (options passed by theme option "language")
\RequirePackage{hyphenat} % Disables hyphenation by using a fake language (provides \nohyphens{})
\RequirePackage[autostyle]{csquotes} % Improves nested quoting (provides \enquote makro for language specific quoting)
\RequirePackage{setspace} % For setstretch
\RequirePackage[calc]{datetime2} % Manages dates and time (needs to be called after babel)

%%% Graphics
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{tikz}
\usetikzlibrary{calc}

%%% Tables and Lists
\RequirePackage{enumitem} % Control layout of itemize, enumerate, description
\RequirePackage[table, figure]{totalcount} % Offers commands for typesetting total values of counters
% TODO: Package footnote has multiple flaws... replace with something more stable (footnotehyper as dropin replacement,footmisc, etc.)
\RequirePackage{footnotehyper} % Footnotes for tables are placed like regular footnotes with makesavenoteenv
\RequirePackage{caption}
\RequirePackage{chngcntr} % Provides \counterwithin and \counterwithout macros to control counter resets and caption labels
%%% Nice-to-Have Packages for easy writing (not needed for template)
\RequirePackage{booktabs, tabularx, longtable} % Table environments
\RequirePackage{multicol, multirow} % Support of multicolumn and multirow

%%% Math
%TODO: Rework math stuff by someone who uses them? Are they needed at all in the default template?
%TODO: mathtools seems to be the replacement for amsmath?
%TODO Change sansmath to https://ftp.fau.de/ctan/fonts/mdsymbol/mdsymbol.pdf for fancy/new/opensans?
\RequirePackage{amsmath,amssymb,amsthm} % Core packaes for AMS math functionality, Theorems

%\RequirePackage{mathrsfs} % Support use of the Raph Smith’s Formal Script font in mathematics. Provides a \mathscr command, rather than overwriting the standard \mathcal command.
\iftoggle{option@math@font@sansserif}{\RequirePackage{sansmath}\sansmath}{}

%%% Index
\RequirePackage{imakeidx} % indices, index (must be loaded before hyperref)


%%% Hyperref
\RequirePackage[hyphens]{url}
\RequirePackage{hyperref} % Links within the document
\RequirePackage[all]{hypcap} % sets hyperref anchor of labes above tables and figures, despite the actual positioning, needs to be loaded after hyperref
\RequirePackage[nameinlink, noabbrev]{cleveref} % Improved referencing system, nameinlink mimics hyperrefs autoref and noabbrev writes full names

%%% Nomenclature/Acronyms, Glossary
% Glossaries needs to be loaded after hyperref (provide glossary and acronyms)
\RequirePackage[toc,nonumberlist,translate=babel,acronym,symbols,shortcuts]{glossaries} % Glossary
% Processes the enddocument-hooks of this class prior to glossaries and therefore avoids glossaries warning of unprocessed printing
\DeclareHookRule{enddocument}{.}{before}{glossaries} 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Colors and hyperlinks

\iftoggle{option@layout@printmode}
{
	\definecolor{hsmw}{cmyk}{1,.5,0,0}
}{
	\definecolor{hsmw}{HTML}{0069b4}
	%	\definecolor{hsmw80}{HTML}{2581c4}
	%	\definecolor{hsmw60}{HTML}{6c9ed4}
	%	\definecolor{hsmw40}{HTML}{a4bde3}
	%	\definecolor{hsmw20}{HTML}{d3ddf2}
	%	\definecolor{hsmw10}{HTML}{e9eef9}
}

% Hyperlinks
\hypersetup
{ 
	breaklinks,
	colorlinks,
	linkcolor={hsmw},
	citecolor={hsmw},
	urlcolor={hsmw},
	bookmarksnumbered, % Include section numbers in pdf bookmarks
	bookmarksopen=true, % Open PDF-Bookmark-Tree
	bookmarksopenlevel=1, % Open only the first level
}
\iftoggle{option@style@colorlinks}{}{\hypersetup{hidelinks}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Spacing of Chapter, Section, Text

% Modify space around chapter, section, etc.
% afterskip of 0pt = single baselineskip due to standalone heading (vs. hanging): get truly 0 with afterskip=-\baselineskip (caution: set afterindent=false): Table 21.1-4
%https://tex.stackexchange.com/questions/223508/adjusting-spacing-around-section-subsection-titles-with-koma-script
\RenewDocumentCommand{\part}{O{#2}m}{\ClassError{\currentClassName}{The command \string\part\space is disabled for this template}{Please don't use \string\part}}
\RedeclareSectionCommands[beforeskip=0pt,afterskip=1\baselineskip plus .5\baselineskip minus .5\baselineskip,tocpagenumberbox=\mbox,afterindent=false]{chapter} % tocpagenumberbox is the box used to layout pagenumbers in toc, prevents overflow of default fixed width box
\RedeclareSectionCommands[beforeskip=0pt plus .5\baselineskip,afterskip=.5\baselineskip plus .5\baselineskip minus .5\baselineskip, tocpagenumberbox=\mbox,runin=false,afterindent=false]{section, subsection, subsubsection}
\RedeclareSectionCommands[beforeskip=0pt, runin=true, afterindent=false]{paragraph, subparagraph}

% Remove pagebreak before chapter if document is a short paper
\iftoggle{option@layout@shortpaper}
{% Since Koma 3.19a: Patch \scr@startchapter instead of \chapter
	\patchcmd{\scr@startchapter}
		{\if@openright\cleardoublepage\else\clearpage\fi}
		{\vspace{\baselineskip}}
		{}
		{\ClassError{\currentClassName}{Failed to patch command for short paper}{Report to the current hsmw-latex curator}}
}{}

% Sets the distance between captions and tables/figures
\KOMAoption{captions}{tableheading, figuresignature} % Formats captions above tables and below figures (placement is still user specific), prevents counter increments on subtable use
%\setlength{\abovecaptionskip}{5\p@}%\p@ = 1pt
%\setlength{\belowcaptionskip}{5\p@}
% Spacing around captions: Sets \abovecaptionskip and \belowcaptionskip based on floating environments
\captionsetup[table]{position=top,skip=.5\baselineskip}
\captionsetup[figure]{position=bottom,skip=.5\baselineskip}
% Spacing around floating environments (including captions)
\setlength{\intextsep}{1\baselineskip plus .25\baselineskip minus .25\baselineskip} % Vertical space above & below [h] floats
\setlength{\textfloatsep}{1\baselineskip plus .25\baselineskip minus .25\baselineskip} % Vertical space below (above) [t] ([b]) floats
\setlength{\floatsep}{2\baselineskip plus .5\baselineskip minus .5\baselineskip} % Vertical space between floats

% General text stretching
\setstretch{1.1}

% Glossary, Acronyms / Nomenclatures
% https://www.dickimaw-books.com/gallery/glossaries-styles/
% https://ctan.mc1.root.project-creative.net/macros/latex/contrib/glossaries/glossaries-user.html#sec:newglossarystyle
\newglossarystyle{hsmw-acronym}
{%
	% \glossarypreamble
	% \glossarypostamble
	\renewenvironment{theglossary}{}{}
	\renewcommand*{\glossaryheader}{}
	\renewcommand*{\glsgroupheading}[1]{} % \glsnavhypertarget{##1}{\glsgetgrouptitle{##1}}\par
	\renewcommand*{\glsgroupskip}{} % \vspace*{.5\baselineskip}
	\renewcommand*{\glossentry}[2]%
	{%
		\parbox[t]{.2\textwidth}%
		{%
			\glsentryitem{##1}%
			\textbf{\glstarget{##1}{\glossentryname{##1}}}%
			%\ifglshassymbol{##1}{ (\glossentrysymbol{##1})}{}%
			\iftoggle{option@style@acronym@dots}{\space\dotfill\space}{}%
		}%
		\parbox[t]{.8\textwidth}{\glossentrydesc{##1}}%
		\\[.5\baselineskip]
	}
	\renewcommand*{\subglossentry}[3]{\glossentry{##2}{##3}}
}
\newglossarystyle{hsmw-symbols}
{%
	% \glossarypreamble
	% \glossarypostamble
	\renewenvironment{theglossary}{}{}
	\renewcommand*{\glossaryheader}{}
	\renewcommand*{\glsgroupheading}[1]{} % \glsnavhypertarget{##1}{\glsgetgrouptitle{##1}}\par
	\renewcommand*{\glsgroupskip}{} % \vspace*{.5\baselineskip}
	\renewcommand*{\glossentry}[2]%
	{%
		\parbox[t]{.2\textwidth}%
		{%
			\glsentryitem{##1}%
			\glstarget{##1}{\ifglshassymbol{##1}{\glossentrysymbol{##1}}{\glossentryname{##1}}}%
			\iftoggle{option@style@symbols@dots}{\space\dotfill\space}{}%
		}%
		\parbox[t]{.8\textwidth}{\ifglshassymbol{##1}{\textbf{\glossentryname{##1}: }}{}\ifglshasdesc{##1}{\glossentrydesc{##1}}{}}%
		\\[.5\baselineskip]
	}
	\renewcommand*{\subglossentry}[3]{\glossentry{##2}{##3}}
}
\iftoggle{option@style@glossary@href}{}{\GlsDeclareNoHyperList{main}}
\iftoggle{option@style@acronym@href}{}{\GlsDeclareNoHyperList{acronym}}
\iftoggle{option@style@symbols@href}{}{\GlsDeclareNoHyperList{symbols}}


% Dictum
\renewcommand{\dictumwidth}{.6\textwidth} % Extend from .33\textwidth
\renewcommand*{\dictumauthorformat}[1]{#1} % Remove default parenthesis

% Statement of Authorship Signature Height
\newlength{\signatureHeight}
\setlength{\signatureHeight}{2.5\baselineskip}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lists

\setlist % All lists (itemize, enumerate, description)
{
	partopsep=\baselineskip, % Vertical space added, to the top and bottom of the entire environment if the list instance is preceded by a blank line.
	topsep=-\baselineskip, % Vertical space added to both the top and bottom of the list, in addition to \parskip
	%
	parsep=0pt, % Vertical space between paragraphs within an item.
	itemsep=0pt, % Vertical space between items, beyond the \parsep.
	after*={\@topsepadd\parskip}, % Adds always a new line after the list
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Footnotes. Chapter 3.14

%Multiple footnote option (\KOMAoption{footnotes}{multiple}) is sadly not compatible with hyperref % Defines a footnote separator if multiple footnotes are specified in a row: \newcommand*{\multfootsep}{,}
%Workaround (https://tex.stackexchange.com/questions/40072/incompatibility-between-footmisc-option-multiple-and-hyperref/62091#62091):
\let\old@footnote\footnote
\newcommand{\next@token}{\relax}
\renewcommand{\footnote}[1]{\old@footnote{#1}\futurelet\nextToken\isFootnote}
\newcommand\isFootnote{\ifx\footnote\nextToken\textsuperscript{,}\fi}

%\deffootnote{1em}{1em}{\textsuperscript{\thefootnotemark}} % \deffootnote[Markenbreite=Einzug]{Einzug}{Absatzeinzug}{Markendefinition}
\counterwithout{footnote}{chapter} % Continuously count footnote (disable reset on chapter)

% Create save environments for floats to place footnotes at end of pages like regular footnotes
\makesavenoteenv{table}
\makesavenoteenv{table*}
\makesavenoteenv{figure}
\makesavenoteenv{figure*}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Header and Footer: Chapter 3.12

\pagestyle{scrheadings}
\clearpairofpagestyles
\ihead*{\headmark}
\ohead*{\pagemark}
\automark[chapter]{chapter} % Sets chapter caption as \headmark
\renewcommand*{\partpagestyle}{scrheadings}
\renewcommand*{\chapterpagestyle}{scrheadings}
\renewcommand*{\indexpagestyle}{scrheadings}

% Index (imakeidx overrides some defaults...)
\indexsetup{firstpagestyle=scrheadings, headers={\indexname}{\indexname}}

\setkomafont{pageheadfoot}{\normalfont\normalcolor\sffamily}
\setkomafont{pagenumber}{\normalfont\normalcolor\sffamily}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Table of Contents (ToC): Chapter 3.9

% Max depth displayed in toc (-1=part, 0=chapter, 1=section, 2=subsection, 3=subsubsection, 4=paragraph, 5=subparagraph)
\setcounter{tocdepth}{3} % 3 = \subsubsectiondepth
% Display numbers on corresponding elements (-1=part, 0=chapter, 1=section, 2=subsection, 3=subsubsection, 4=paragraph, 5=subparagraph)
\setcounter{secnumdepth}{3} % 3 = \subsubsectionnumdepth

% Entries to include into the toc
\setuptoc{toc}{totoc} % Inserts ToC into ToC
\setuptoc{lof}{totoc} % Figures
\setuptoc{lot}{totoc} % Tables
\KOMAoption{toc}{bib} % Bibliography and Index (unfortunately these are not working with setuptoc...)

% ToC styling options
\iftoggle{option@style@toc@graduated}
{
	\KOMAoption{toc}{graduated}
	\KOMAoption{listof}{graduated}
}{
	\KOMAoption{toc}{flat}
	\KOMAoption{listof}{flat, nochaptergap}
		
	% Change line spacing to doublespacing (adding doublespacing to begin of auxiliary files)
	%	\addtocontents{toc}{\protect\doublespacing} % ToC
	%	\addtocontents{lot}{\protect\doublespacing} % Tables
	%	\addtocontents{lof}{\protect\doublespacing} % Figures
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Captions (Tables and Figures): Chapter 3.20

% Changes the caption label everywhere (lot, lof, \ref)
\iftoggle{option@style@caption@label@minus}
{
	\renewcommand{\thefigure}{\thechapter-\arabic{figure}} % Original: \thechapter.\arabic{figure}
	\renewcommand{\thetable}{\thechapter-\arabic{table}}
	\renewcommand{\theequation}{\thechapter-\arabic{equation}}
}{}
% Do not reset the counters on new chapter and therefore continuously count tables, figures and equations
\iftoggle{option@style@caption@label@nochapter}
{
	\counterwithout{table}{chapter}
	\counterwithout{figure}{chapter}
	\counterwithout{equation}{chapter}
}{}

% Sets the format of the delimiter between caption label and caption text
%\renewcommand*{\captionformat}{:~~} % original: ":\ "

\addtokomafont{caption}{\small}
\addtokomafont{captionlabel}{\small\bfseries}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Datetime

\DTMsetup{datesep=.}
\DTMnewdatestyle{hsmwyearstyle}% Display only the year
{%
	\renewcommand*{\DTMdisplaydate}[4]%year, month, day, dow
	{##1}%
	\renewcommand*{\DTMDisplaydate}{\DTMdisplaydate}%
}
\DTMnewdatestyle{hsmwmonthstyle}% Display day. monthname year
{%
	\renewcommand*{\DTMdisplaydate}[4]%year, month, day, dow
	{%
		\ifnumgreater{##3}{0}{\DTMtwodigits{##3}.~}{}%
		\ifnumgreater{##2}{0}{\DTMMonthname{##2}~}{}%
		##1%
	}%
	\renewcommand*{\DTMDisplaydate}{\DTMdisplaydate}%
}
\DTMnewdatestyle{hsmwshortmonthstyle}% Display monthname year
{%
	\renewcommand*{\DTMdisplaydate}[4]%year, month, day, dow
	{%
		\ifnumgreater{##2}{0}{\DTMMonthname{##2}~}{}%
		##1%
	}%
	\renewcommand*{\DTMDisplaydate}{\DTMdisplaydate}%
}
\DTMnewdatestyle{hsmwnumericstyle}% Display two digit day.month.year
{%
	\renewcommand*{\DTMdisplaydate}[4]%year, month, day, dow
	{%
		\DTMtwodigits{##3}\DTMsep{monthday}%
		\DTMtwodigits{##2}\DTMsep{yearmonth}%
		##1%
	}%
	\renewcommand*{\DTMDisplaydate}{\DTMdisplaydate}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Commands

% Convenience command for creation of symbols
\NewDocumentCommand{\newsymb}{mmmm}% label, symbol, name, description
{
	\newglossaryentry{#1}
	{
		type=symbols,
		name={#3},
		description={#4},
		symbol={#2},
	}
}

\newtoggle{logo@partner@content}
\newcommand{\logo@partner@height}{}
\newcommand{\logo@partner}{}
\NewDocumentCommand{\insert@partnerlogo}{o}
{%
	\ifdefempty{\logo@partner}%
	{}
	{%
		\iftoggle{logo@partner@content}
		{\logo@partner}
		{%
			\ifdefempty{\logo@partner@height}
			{\includegraphics[height=\dimexpr#1\relax]{\logo@partner}}
			{\includegraphics[height=\logo@partner@height]{\logo@partner}}%
		}%
	}%
}
\NewDocumentCommand{\partnerlogo}{som}% interpret path as actual content*, [explicit height], path
{
	\IfBooleanTF{#1}
	{\settoggle{logo@partner@content}{true}}
	{\settoggle{logo@partner@content}{false}}
	
	\IfNoValueTF{#2}
	{\renewcommand{\logo@partner@height}{}}
	{\renewcommand{\logo@partner@height}{#2}}
	
	\renewcommand{\logo@partner}{#3}
}

% Execute last minute code in preamble
\newcommand{\insert@preamble}{}
\NewDocumentCommand{\hookpreamble}{+m}{\renewcommand{\insert@preamble}{#1}}

% Add additional listings after toc, lof and lot
\newcommand{\insert@hook@lists@compact}{}
\newcommand{\insert@hook@lists@regular}{}
\newcommand{\insert@hook@lists}{}
\NewDocumentCommand{\hooklists}{+o+o+m}
{
	\IfNoValueF{#1}{\renewcommand{\insert@hook@lists@compact}{#1}}
	\IfNoValueF{#2}{\renewcommand{\insert@hook@lists@regular}{#2}}
	\renewcommand{\insert@hook@lists}{#3}
}

% Change the default \printbibliography to something else
\newcommand{\insert@bibliography@before}
{
	% If the bibliography would break the page border, just clip the url on any character	
	\ifltxcounter{biburlnumpenalty}{\setcounter{biburlnumpenalty}{9000}}{}% numbers
	\ifltxcounter{biburllcpenalty}{\setcounter{biburllcpenalty}{9000}}{}% lowercase letters
	\ifltxcounter{biburlucpenalty}{\setcounter{biburlucpenalty}{9000}}{}% uppercase letters
	
	% If biblatex is not loaded, provide an empty command for bibliography
	\providecommand{\printbibliography}{}
}
\newcommand{\insert@bibliography}{\printbibliography}
\NewDocumentCommand{\hookbibliography}{+o+m}
{
	\IfNoValueF{#1}{\renewcommand{\insert@bibliography@before}{#1}}
	\renewcommand{\insert@bibliography}{#2}
}

\newcommand{\insert@lot@before}{}
\newcommand{\insert@lot@after}{}
\NewDocumentCommand{\hooklot}{+m+m}
{
	\renewcommand{\insert@lot@before}{#1}
	\renewcommand{\insert@lot@after}{#2}
}

\newcommand{\insert@lof@before}{}
\newcommand{\insert@lof@after}{}
\NewDocumentCommand{\hooklof}{+m+m}
{
	\renewcommand{\insert@lof@before}{#1}
	\renewcommand{\insert@lof@after}{#2}
}

\newcommand{\insert@between@index@soa}{}
\NewDocumentCommand{\hookpreauthorship}{+m}{\renewcommand{\insert@between@index@soa}{#1}}

\newcommand{\insert@lastpage}{}
\NewDocumentCommand{\hooklastpage}{+m}{\renewcommand{\insert@lastpage}{#1}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% User Commands

\newcommand{\@type@german}{}
\newcommand{\@type@english}{}
\NewDocumentCommand{\type}{om}% [english], deutsch
{
	\IfNoValueF{#1}{\renewcommand{\@type@english}{#1}}
	\renewcommand{\@type@german}{#2}
}

\newcounter{author@amount}
\newtoggle{author@gender}
\newcommand{\@author@format}[7]{#3 #4}% Use newcommand instead of NewDocumentCommand to avoid robustness
\RenewDocumentCommand{\author}{sd()O{}mmO{}D<>{}D<>{}}% femalesalutation*, (salutation overwrite), [title], prename, surname, [acad], <signaturefilepath>, <signatureShift>
{
	\setcounter{author@amount}{0}

	\edef\local@prefix%
	{%
		\IfBooleanT{#1}{*}%
		\IfNoValueF{#2}{(#2)}%
	}
	\expandafter\addauthor\local@prefix[#3]{#4}{#5}[#6]<#7><#8>
}
\NewDocumentCommand{\addauthor}{sd()O{}mmO{}D<>{}D<>{}}% femalesalutation*, (salutation overwrite), [title], prename, surname, [acad], <signaturefilepath>, <signatureShift>
{
	\ifnumequal{\value{author@amount}}{0}
	{
		% Switch gender toggle to female (for label)
		\IfBooleanTF{#1}{\settoggle{author@gender}{true}}{\settoggle{author@gender}{false}}
		% Reset default latex noauthor warning
		\renewcommand{\@author}{}	
	}{
		% Set gender toggle for label to false if not all have the same gender
		\IfBooleanF{#1}{\settoggle{author@gender}{false}}
		
		% Using etoolbox appto instead of newer AddToHook due to time of insertion (instant vs later on)
		\appto{\@author}{\and}
	}
	
	% Using etoolbox appto instead of newer AddToHook due to time of insertion (instant vs later on)
	\appto{\@author}
	{%
		\@author@format%
		{\IfNoValueTF{#2}{\IfBooleanTF{#1}{\GetMultiLanguageLabel{salutationfemale}}{\GetMultiLanguageLabel{salutationmale}}}{#2}}% Salutation
		{#3}% Title (Prof. Dr.)
		{#4}% Prename
		{#5}% Surname
		{#6}% Academic Degree (M.Sc.)
		{#7}% Signature File
		{#8}% Signature File Shift
	}
	
	\stepcounter{author@amount}
}

\newcommand{\@title@english}{}
\RenewDocumentCommand{\title}{om}% [english], deutsch
{
	\IfNoValueF{#1}{\renewcommand{\@title@english}{#1}}
	\renewcommand{\@title}{#2}
}

\newcommand{\@subtitle@english}{}
\RenewDocumentCommand{\subtitle}{om}% [english], deutsch
{
	\IfNoValueF{#1}{\renewcommand{\@subtitle@english}{#1}}
	\renewcommand{\@subtitle}{#2}
}

\newcommand{\@date@submission}{}
\NewDocumentCommand{\submissiondate}{smoo}% use year as fixed value*, year, [month], [day]
{
	\IfBooleanTF{#1}%starred version uses year as fixed content
	{\renewcommand{\@date@submission}{#2}}
	{
		\def\submission@year{#2}
		\edef\submission@month{\IfNoValueTF{#3}{0}{#3}}
		\edef\submission@day{\IfNoValueTF{#4}{0}{#4}}
		
		\DTMsavenoparsedate{date@submission}
		{\submission@year}
		{\submission@month}
		{\submission@day}
		{-1}%disable dow
		
		\renewcommand{\@date@submission}{\DTMusedate{date@submission}}
	}
}
\newcommand{\@date@defense}{}
\NewDocumentCommand{\defensedate}{smoo}% use year as fixed value*, year, [month], [day]
{
	\IfBooleanTF{#1}%starred version uses year as fixed content
	{\renewcommand{\@date@defense}{#2}}
	{
		\edef\defense@year{#2}
		\edef\defense@month{\IfNoValueTF{#3}{0}{#3}}
		\edef\defense@day{\IfNoValueTF{#4}{0}{#4}}
		
		\DTMsavenoparsedate{date@defense}
		{\defense@year}
		{\defense@month}
		{\defense@day}
		{-1}%disable dow
		
		\renewcommand{\@date@defense}{\DTMusedate{date@defense}}
	}
}

\newcommand{\@location}{}
\NewDocumentCommand{\location}{m}
{\renewcommand{\@location}{#1}}

\newcommand{\@faculty@german}{}
\newcommand{\@faculty@english}{}
\NewDocumentCommand{\faculty}{om}% [english], deutsch
{
	\IfNoValueF{#1}{\renewcommand{\@faculty@english}{#1}}
	\renewcommand{\@faculty@german}{#2}
}

\newcommand{\@courseofstudy@german}{}
\newcommand{\@courseofstudy@english}{}
\NewDocumentCommand{\courseofstudy}{om}% [english], deutsch
{
	\IfNoValueF{#1}{\renewcommand{\@courseofstudy@english}{#1}}
	\renewcommand{\@courseofstudy@german}{#2}
}

\newcommand{\@module}{}
\NewDocumentCommand{\module}{m}
{\renewcommand{\@module}{#1}}

\newcommand{\@seminargroup}{}
\NewDocumentCommand{\seminargroup}{m}
{\renewcommand{\@seminargroup}{#1}}

%RÖBBE
\newcommand{\@betreuer}{}
\NewDocumentCommand{\betreuer}{m}
{\renewcommand{\@betreuer}{#1}}

\newcommand{\@email}{}
\NewDocumentCommand{\email}{m}
{\renewcommand{\@email}{#1}}

\newcounter{examiner@amount}
\newtoggle{examiner@genders}
\NewDocumentCommand{\examiner}{somO{}}% femalesalutation*, [title], name, [degree]
{
	%TODO: Clears warning for second examiner if used alone in thesis mode
	% Reset all currently defined values
	\foreach \i in {1,...,\theexaminer@amount}
	{		
		\expandafter\gundef\csname @examiner@name@\i\endcsname
		\expandafter\gundef\csname examiner@gender@\i\endcsname
	}
	
	% Reset counter
	\setcounter{examiner@amount}{0}
	
	% Pass parameters
	\edef\local@prefix%
	{%
		\IfBooleanT{#1}{*}%
		\IfNoValueF{#2}{[#2]}%
	}
	\expandafter\addexaminer\local@prefix{#3}[#4]
}
\NewDocumentCommand{\addexaminer}{somO{}}% femalesalutation*, [title], name, [degree]
{
	\stepcounter{examiner@amount} % Start index at 1 for easier handling of for-loop
	
	\edef\temp@gender{examiner@gender@\theexaminer@amount}
	\edef\temp@name{@examiner@name@\theexaminer@amount}
	
	% Configure examiner name
	\expandafter\providecommand\csname\temp@name\endcsname{}
	\expandafter\renewcommand\csname\temp@name\endcsname{\IfNoValueF{#2}{#2 }#3\ifstrempty{#4}{}{, #4}}
	
	% Confiure individual gender toggle for each examiner
	\providetoggle{\temp@gender}	
	\IfBooleanTF{#1}{\settoggle{\temp@gender}{true}}{\settoggle{\temp@gender}{false}}

	\ifnumequal{\value{examiner@amount}}{1}
	{
		% Switch overall gender toggle to female (for label)
		\IfBooleanT{#1}{\settoggle{examiner@genders}{true}}
	}{
		% Set gender toggle for label to false if not all have the same gender
		\IfBooleanF{#1}{\settoggle{examiner@genders}{false}}
	}
}
\newcommand{\examinernames}
{%
	\foreach \i in {1,...,\theexaminer@amount}%
	{%
		\ifdefstring{\i}{1}{}{\and}%
		\examinername{\i}%
	}%
}
\newcommand{\examinername}[1]{\ifcsempty{@examiner@name@#1}{}{\csname @examiner@name@#1\endcsname}}


\newcommand{\@abstract@german}{}
\newcommand{\@abstract@english}{}
\newcommand{\@abstract@delim}{}
\NewDocumentCommand{\abstract}{+O{}+mO{}}
{
	\renewcommand{\@abstract@english}{#1}
	\renewcommand{\@abstract@german}{#2}
	\renewcommand{\@abstract@delim}{#3}
}

\newcommand{\@preface}{}
\NewDocumentCommand{\preface}{+oo+m}% [dictum], [dictumauthor], preface
{
	\renewcommand{\@preface}
	{
		\ifstrempty{#3}{}
		{
			\IfNoValueF{#1}{\setchapterpreamble[u]{\dictum[\IfNoValueF{#2}{#2}]{#1}}}
			\addchap{\prefacename}
			#3
		}
	}
}

\renewcommand{\@dedication}{}
\RenewDocumentCommand{\dedication}{+oo+m}% [dictum], [dictumauthor], dedication
{
	\renewcommand{\@dedication}
	{
		\ifstrempty{#3}{}
		{
			\IfNoValueF{#1}{\setchapterpreamble[u]{\dictum[\IfNoValueF{#2}{#2}]{#1}}}
			\addchap{\GetMultiLanguageLabel{dedicationname}}
			#3
		}
	}
}

\newcommand{\@nondisclosureagreement@party}{}
\NewDocumentCommand{\nda}{+m}
{\renewcommand{\@nondisclosureagreement@party}{#1}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Default values

% Mandatory
\type[\option@preset@thesis@name]{\option@preset@thesis@name}
\renewcommand{\@author}{\PrintWarning*[AUTOR]{Bitte Autor(en) angeben}}
\submissiondate*{\PrintWarning*[ABGABEDATUM]{Bitte Abgabedatum angeben}}

\iftoggle{option@layout@paper}
{
	\title{\PrintWarning*[TITEL]{Bitte einen Titel angeben}}
	\ifdefempty{\option@preset@faculty@name}
	{}{\faculty[\option@preset@faculty@name]{\option@preset@faculty@name}}
}{
	\title[\iftoggle{option@layout@secondtitle}{\PrintWarning*[ENGLISH TITLE]{Please specify english title}}{}]{\PrintWarning*[DEUTSCHER TITEL]{Bitte einen deutschen Titel angeben}}
	\ifdefempty{\option@preset@faculty@name}
	{\faculty[\iftoggle{option@layout@secondtitle}{\PrintWarning*[FACULTY NAME]{Please specify a faculty name}}]{\PrintWarning*[FAKULTÄT]{Bitte Fakultätsnamen angeben}}}
	{\faculty[\option@preset@faculty@name]{\option@preset@faculty@name}}
	\courseofstudy[\iftoggle{option@layout@secondtitle}{\PrintWarning*[COURSE OF STUDY]{Please specify course of study}}]{\PrintWarning*[STUDIENGANG]{Bitte Studiengang angeben}}
	\seminargroup{\PrintWarning*[SEMINARGROUP]{Bitte Seminargruppe angeben}}
    %RÖBBE
    %\supervisor{\PrintWarning*[BETREUER]{Bitte weiteren Betreuer angeben}}
	\examiner{\PrintWarning*[N. N.]{Bitte Erstprüfer angeben}}
	\addexaminer{\PrintWarning*[N. N.]{Bitte Zweitprüfer angeben}}
	\defensedate*{\@date@submission}
	\abstract{\PrintWarning*[Bitte eine Kurzbeschreibung mittels \string\abstract\space in der Präambel angeben!
		Bei Bedarf kann auch eine zusätzliche englische Beschreibung als optionales Argument eingefügt werden.
		Das Kurzreferat (\textit{Abstract}) gibt den wesentlichen Inhalt einer wissenschaftlichen Arbeit in wenigen Sätzen ohne Interpretation und Wertung wieder.
		Dabei soll der Titel der Arbeit nicht wiederholt, sondern anhand informativer Aussagen erläutert werden.]{Bitte Referat angeben}}
}

% Optional
\location{Mittweida}
\date{\today}




% Optional values without default values
%\subtitle[]{}
%\iftoggle{option@layout@paper}
%{
%	\courseofstudy{}{}
%	\seminargroup{}
%	\email{}
%}{
%	\preface{}
%	\dedication{}
%	\nda{}
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Finetuning

%% Patch underline-Command to smash its contents and destroy the bounding box, thus drawing a nice baseline-underline
%\let\oldunderline\underline
%\renewcommand{\underline}[1]{\oldunderline{\smash{#1}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Math environments (taken from previous template and not touched for comfort)
%TODO: Rework math stuff by someone who uses them? Are they needed at all in the default template?

% Theoreme, Definitionen usw.
\def\thmafterhead{}
\def\thmafterheadspace{}
\iftoggle{option@math@theorem@below}
{
	\def\thmafterhead{\newline}
	\def\thmafterheadspace{0pt}
}{
	\def\thmafterhead{\newline}
	\def\thmafterheadspace{.6em}
}

\newtheoremstyle{plain}{5mm}{0mm}{\itshape}{}{\bfseries}{\option@math@theorem@delimiter\thmafterhead}{\thmafterheadspace}{}
\newtheoremstyle{definition}{5mm}{0mm}{\upshape}{}{\bfseries}{\option@math@theorem@delimiter\thmafterhead}{\thmafterheadspace}{}
\newtheoremstyle{remark}{5mm}{0mm}{\upshape}{}{\itshape}{\option@math@theorem@delimiter\thmafterhead}{\thmafterheadspace}{}
\newtheoremstyle{plain*}{5mm}{0mm}{\itshape}{}{\bfseries}{\option@math@theorem@delimiter\thmafterhead}{\thmafterheadspace}{}
\newtheoremstyle{definition*}{5mm}{0mm}{\upshape}{}{\bfseries}{\option@math@theorem@delimiter\thmafterhead}{\thmafterheadspace}{}
\newtheoremstyle{remark*}{5mm}{0mm}{\upshape}{}{\itshape}{\option@math@theorem@delimiter\thmafterhead}{\thmafterheadspace}{}

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Switches for primary parts

\renewcommand{\frontmatter}%
{%
	\cleardoublepage%
	\iftoggle{option@style@frontmatter@pagenumber@smallromans}{\pagenumbering{roman}}{\pagenumbering{Roman}}%
	\pagestyle{scrheadings}%
}
\renewcommand{\mainmatter}%
{%
	\cleardoublepage%
	\pagenumbering{arabic}%
	\pagestyle{scrheadings}%
	\renewcommand*{\chaptermarkformat}{\chaptername~\thechapter:\enskip}% Format of chapter name in headings
}
\newtoggle{@backmatter}
\renewcommand{\backmatter}%
{%
	% First call to backmatter (appendix or remaining auto tables): set last content page
	\iftoggle{@backmatter}{}{%
		\settoggle{@backmatter}{true}%
		\label{page:lastcontent}%
		\cleardoublepage%
		\pagestyle{scrheadings}%
		%\pagenumbering{roman}%
	}%
}
\newcommand*{\appendixmore}% Will be called by /appendix if defined
{
	\renewcommand*{\chapterformat}{\appendixname~\thechapter:\enskip}
	\renewcommand*{\chaptermarkformat}{\appendixname~\thechapter:\enskip}
}
\AddToHook{cmd/appendix/before}% Patch backmatter and phantomsection right before appendix
{
	\backmatter%
	% Add "Appendix" into toc before appendices
	\phantomsection%
	\addcontentsline{toc}{chapter}{\appendixname}%
	%\pdfbookmark{\appendixname}{bookmarklabelappendix} % same version, but only as only as pdf bookmark, not into toc
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Title pages

% Setting geometry in preamble may fail due to not selected baselineskip for font, therefore place here
\AddToHook{begindocument/end}{
	\newgeometry{
		top=\dimexpr 20mm + \baselineskip\relax,
		inner=35mm,
		outer=20mm,
		bottom=26mm,
		headheight=\baselineskip,
		headsep=\baselineskip,
		marginparsep=2.5mm,
		marginparwidth=15mm,
		ignoreheadfoot
	}
}

\RenewDocumentCommand{\maketitle}{}
{%
	\pagestyle{empty}% No header or footer
	\pagenumbering{alph}% Set pagenumbering to small alphanummeric to prevent clashes in PDF exports
	\hypersetup{pageanchor=false}% Disable Hyperref for title page due to missing visible numbering
	\iftoggle{option@layout@paper}
	{
		\begin{titlepage}
			\MakeExtraTitle
		\end{titlepage}
	}{%
		\begin{titlepage}%
			\MakeExtraTitle%
			\MakeNormalTitle{\@faculty@german}{\@type@german}{\@title}{\@subtitle}{\@courseofstudy@german}%
			\iftoggle{option@layout@secondtitle}
			{%
				\begin{otherlanguage}{english}%
					\MakeNormalTitle{\@faculty@english}{\@type@english}{\@title@english}{\@subtitle@english}{\@courseofstudy@english}%
				\end{otherlanguage}%
			}{}%
		\end{titlepage}%
		
		\cleardoublepage
		\minisec{\GetMultiLanguageLabel{bibliographicdescription}\@abstract@delim}%
		\BibliograficData%
		\BibliograficDataAdditional
		
		\vfill
		
		% Kurzreferat % DIN 1426
		\ifdefempty{\@abstract@german}{}{\begin{otherlanguage}{ngerman}\minisec{\GetMultiLanguageLabel{abstract}\@abstract@delim}\@abstract@german\end{otherlanguage}}
		\ifdefempty{\@abstract@english}{}{\begin{otherlanguage}{english}\minisec{\GetMultiLanguageLabel{abstract}\@abstract@delim}\@abstract@english\end{otherlanguage}}
	}
	
	\frontmatter
	\hypersetup{pageanchor=true}	
	\tableofcontents
	
	\cleardoublepage%
	\InsertAdditionalLists
	
	\@preface
	\@dedication

	\mainmatter
}



% Extra title ("Schmutztitel")
\NewDocumentCommand{\MakeExtraTitle}{}
{%
	\InsertStyleElement%
	%
	\begin{minipage}[b][\textheight][t]{93mm}%
		\raggedleft
		\normalsize
		\vspace*{-\baselineskip}
		\Huge
		\vspace*{\dimexpr 98mm - 20mm - \baselineskip\relax}
		
		\iftoggle{option@layout@paper}
		{
			\begingroup
			\small
			\vspace*{-\baselineskip}
			\ifdefempty{\@faculty@german}%\expandafter\ifdefempty\expandafter{\@faculty@german}
			{\strut}
			{
				\GetMultiLanguageLabel{faculty}
				\textbf{\@faculty@german}
			}\\
			\vspace*{-2\baselineskip}
			\endgroup
		}{}
		\rule{\linewidth}{0.5pt}\\
		\vspace*{.5\baselineskip}
		\strut\textbf{\MakeUppercase{\@type@german}}\\
		\rule{\linewidth}{0.5pt}\\
		
		\vspace*{1\baselineskip plus 1fill}
		\iftoggle{option@layout@paper}
		{}{
			\small
			\begingroup
			\ifnumgreater{\value{author@amount}}{1}
			{
				\def\and{\\}
				\renewcommand{\@author@format}[7]%
				{##1 \ifstrempty{##2}{}{##2 }\textbf{##3 ##4}\ifstrempty{##5}{}{, ##5}}% salutation*, [title], prename, surname, [acad], <signaturefilepath>, <signatureShift>
			}{
				\renewcommand{\@author@format}[7]%
				{##1 \ifstrempty{##2}{}{##2}\\\textbf{##3 ##4}\ifstrempty{##5}{}{, ##5}}% salutation*, [title], prename, surname, [acad], <signaturefilepath>, <signatureShift>
			}
			\strut\@author\\
			\endgroup
			\vspace*{\baselineskip}
		}
		\Large
		\strut\textbf{\nohyphens{\@title}}\\
		\normalsize
		\ifdefempty{\@subtitle}
		{}{%
			\vspace*{\baselineskip}
			\strut\textbf{\nohyphens{\@subtitle}}\\
		}
		
		\iftoggle{option@layout@paper}
		{
			\small
			\vspace*{1\baselineskip plus 1fill}
			\begingroup
				\ifnumgreater{\value{author@amount}}{1}
				{
					\def\and{\\}
					\renewcommand{\@author@format}[7]%
					{##1 \ifstrempty{##2}{}{##2 }\textbf{##3 ##4}\ifstrempty{##5}{}{, ##5}}% salutation*, [title], prename, surname, [acad], <signaturefilepath>, <signatureShift>
				}{
					\renewcommand{\@author@format}[7]%
					{##1 \ifstrempty{##2}{}{##2}\\\textbf{##3 ##4}\ifstrempty{##5}{}{, ##5}}% salutation*, [title], prename, surname, [acad], <signaturefilepath>, <signatureShift>
				}
				\strut\@author\\
			\endgroup
			
			\vspace*{1\baselineskip plus 1fill}
			\ifdefempty{\@courseofstudy@german}
			{}{%
				\vspace*{\baselineskip}
				\GetMultiLanguageLabel{courseofstudy}:\\
				\strut\@courseofstudy@german\\
			}
			
			\ifdefempty{\@module}
			{}{%
				\vspace*{\baselineskip}
				\GetMultiLanguageLabel{module}:\\
				\strut\@module\\
			}
		
			\ifdefempty{\@seminargroup}
			{}{%
				\vspace*{\baselineskip}
				\GetMultiLanguageLabel{seminargroup}:\\
				\strut\@seminargroup\\
			}

            %RÖBBE
            \ifdefempty{\@betreuer}
			{}{%
				\vspace*{\baselineskip}
				\GetMultiLanguageLabel{betreuer}:\\
				\strut\@betreuer\\
			}
			
			\ifdefempty{\@email}
			{}{%
				\vspace*{\baselineskip}
				\GetMultiLanguageLabel{email}:\\
				\strut{\def\and{\\}\@email}\\
			}
			\ifnumequal{\value{examiner@amount}}{0}
			{}{%
				\vspace*{\baselineskip}
				\GetMultiLanguageLabel{supervisor}:\\
				\strut{\def\and{\\}\examinernames}\\
			}

           
		}{}	
		
		\vspace*{2\baselineskip plus 1fill minus 1\baselineskip}
		\small
		Mittweida,%
		\begingroup
			\iftoggle{option@layout@paper}{\DTMsetdatestyle{hsmwmonthstyle}}{\DTMsetdatestyle{hsmwshortmonthstyle}}
			\@date@submission
		\endgroup
		
		\vspace*{2cm plus 1fill}
		\phantom{.}
	\end{minipage}%
	\iftoggle{option@layout@paper}%
	{}{%
		\clearpage
		\@frontispiece
	}%
}
\NewDocumentCommand{\InsertStyleElement}{}
{%
	\begin{tikzpicture}[remember picture, overlay]
		\iftoggle{option@style@fancy}
		{
			\node[anchor=north east, inner sep=0, outer sep=0] (logohsmw) at (current page.north east) {\logo[hsmw]{white}{94mm}}; 
			\node[anchor=south east, inner sep=0, outer sep=0] at (current page.south east) {\logoDesignBackgroundBottom{hsmw}{94mm}};
			
			% Partnerlogo
			\ifdefempty{\logo@partner}
			{}
			{
				\logoScaleToWidth**{94mm}
				\node[inner sep=0, outer sep=0, anchor=east] at ([xshift=-3\luw-2\luws] logohsmw.west) {\insert@partnerlogo[\luh+\luhx+\luhs]};
			}
			
			% DEBUG
%			\draw[color=red] (current page.north east) -| ++(-9.4, -4.8) -| cycle;
%			\draw[color=red] (current page.south east) -| ++(-9.4, 2.6) -| cycle;
%			\draw[blue] (current page.north west) ++(35mm, 0) |- ++(93mm, -98mm);
		}{
			\node[inner sep=0, outer sep=0, anchor=north east] (logohsmw) at ([xshift=-22mm, yshift=-11mm]current page.north east) {\logo{hsmw}{55mm}};
			
			% Partnerlogo
			\ifdefempty{\logo@partner}
			{}
			{
				\logoScaleToWidth{55mm}
				\draw[hsmw, line width=1pt] ([xshift=-\luw] logohsmw.north west) to ([xshift=-\luw] logohsmw.south west);
				\node[inner sep=0, outer sep=0, anchor=east] at ([xshift=-2\luw-1pt] logohsmw.west) {\insert@partnerlogo[\luh+\luhx+\luhs]};
			}
				
			% DEBUG
			%\draw[red] (current page.north east) ++(-22mm, -11mm) -| ++(-55mm, -5mm) -| ++(-5mm, -5mm) -| ++(-93mm, -5mm);		
			%\draw[blue] (current page.north west) ++(35mm, 0) |- ++(93mm, -98mm);
		}
	\end{tikzpicture}%
}

% Normal title
\NewDocumentCommand{\MakeNormalTitle}{mmmmm}% Faculty, Type, Title, Subtitle, CourseOfStudy
{%
	\cleardoublepage%
	\begin{minipage}[b][\textheight][t]{93mm}%
		\raggedleft
		\vspace*{2cm}
		\small
		\ifdefempty{#1}
		{\strut}
		{
			\GetMultiLanguageLabel{faculty}
			\textbf{#1}\ignorespaces
		}
		
		\LARGE
		\vspace*{-.75\baselineskip}
		\rule{\linewidth}{0.5pt}\\
		\strut\textbf{\MakeUppercase{#2}}\\
		\vspace*{-.5\baselineskip}
		\rule{\linewidth}{0.5pt}\\
		
		\vspace*{2\baselineskip plus 1fill}
		\strut\Large\textbf{\nohyphens{#3}}\\
		
		\ifstrempty{#4}
		{}{%
			\vspace*{\baselineskip}
			\normalsize
			\strut\textbf{\nohyphens{#4}}\\
		}
		\vspace*{2\baselineskip plus 1fill}	
		
		\small
		\GetMultiLanguageLabel{author}:\\
		\strut{\def\and{\\}\textbf{\@author}}\\
		
		\vspace*{\baselineskip}
		\GetMultiLanguageLabel{courseofstudy}:\\
		\strut#5\\
		
		\vspace*{\baselineskip}
		\GetMultiLanguageLabel{seminargroup}:\\
		\strut\@seminargroup\\

        %TODO: Matriculation number is not specified in corporate design, but would fit here
		
		\vspace*{\baselineskip}
		\GetMultiLanguageLabel{examiner@1}:\\
		\strut\examinername{1}\\
		
		\vspace*{\baselineskip}
		\GetMultiLanguageLabel{examiner@2}:\\
		\strut\examinername{2}\\
		
        %RÖBBE
        \ifdefempty{\@betreuer}
		{}{%
			\vspace*{\baselineskip}
			\GetMultiLanguageLabel{betreuer}:\\
			\strut\@betreuer\\
		}
        

		\vspace*{\baselineskip}
		\GetMultiLanguageLabel{submission}:\\
		Mittweida,%
		\begingroup
			\DTMsetdatestyle{hsmwnumericstyle}
			\@date@submission
		\endgroup
		
		\vspace*{\baselineskip}
		\GetMultiLanguageLabel{defense}:\\
		Mittweida,%
		\begingroup
			\DTMsetdatestyle{hsmwyearstyle}
			\@date@defense
		\endgroup
		
		\vfill
		\phantom{.}
	\end{minipage}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Bibliographic Description

\NewDocumentCommand{\BibliograficData}{} 
{% DIN 1505, Teil 1
	{\def\and{; }\renewcommand{\@author@format}[7]{##4, ##3}\@author}:\\
	\ifdefempty{\@subtitle}{\@title.}{\@title, \textit{\@subtitle}.}
	--%
	\begingroup
		\DTMsetdatestyle{hsmwyearstyle}
		\@date@submission.
	\endgroup
	-- \pageref*{page:lastcontent} S.\\ 
	Mittweida, 
	Hochschule Mittweida -- University of Applied Sciences,
	\GetMultiLanguageLabel{faculty} \@faculty@german,
	\@type@german,%
	\begingroup
		\DTMsetdatestyle{hsmwyearstyle}
		\@date@defense.
	\endgroup
			
	%TODO: Check specified page numbers in DIN 1505, Part1: Only content pages vs frontmatter/mainmatter/backmatter vs additional amount of tables/figures/bibentries
	%
	%	\@comma{\nofigures}\@comma{\notables}\@comma{\@Anlagen}\@comma{\Hochschule}
	%%	Die bibliographische Beschreibung sollte zu den festen Bestandteilen jedes
	%%	wissenschaftlichen Werkes gehören und ist nach DIN 1505 Teil 1 abzufassen. Dabei sind die
	%%	einzelnen Bestandteile, deren Reihenfolge und die Zeichensetzung zwischen den
	%%	Bestandteilen fest vorgegeben .
	%	Bibliografische Beschreibung:\\
	%	\@author: \@title. -- SUBMISSION-YEAR. -- X S.\\
	%	Mittweida, Hochschule Mittweida -- University of Applied Sciences, \@faculty, \@subject, DEFENSE-YEAR\\
}
\NewDocumentCommand{\BibliograficDataAdditional}{}
{%
	% Non-Disclosure Agreement
	\ifdefempty{\@nondisclosureagreement@party}
	{}{%
		\minisec{\GetMultiLanguageLabel{nda@title}:}
		\GetMultiLanguageLabel{nda@text}
	}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List of Figures and Tables

\newcounter{figuresandtables}

\NewDocumentCommand{\InsertAdditionalLists}{}
{
	% Counts figures and tables together
	\setcounter{figuresandtables}{0}
	\iftotaltables\addtocounter{figuresandtables}{\totaltables}\fi
	\iftotalfigures\addtocounter{figuresandtables}{\totalfigures}\fi

	\iftoggle{option@layout@listof@compact}
	{
		\def\currentChapterHeading{}
		\ifboolexpr{test{\ifdefempty{\insert@hook@lists}} and test{\ifdefempty{\insert@hook@lists@compact}}}
		{
			\iftoggle{option@layout@listof@tablesfirst}
			{\def\currentChapterHeading{\GetMultiLanguageLabel{listoftablesandfigures}}}
			{\def\currentChapterHeading{\GetMultiLanguageLabel{listoffiguresandtables}}}
		}{
			\def\currentChapterHeading{\GetMultiLanguageLabel{additionallists}}
		}
		
		\KOMAoption{listof}{leveldown,notoc}% Change chapter captions to section captions and remove from toc
		\iftoggle{option@layout@listof@tablesfirst}
		{
			\ifnumcomp{\value{figuresandtables}}{=}{0}{}
			{
				\ifboolexpr{test{\ifdefempty{\insert@lot@before}} and test{\ifdefempty{\insert@lof@before}}}{}
				{\setchapterpreamble[u]{\insert@lot@before\insert@lof@before}}
				\addchap{\currentChapterHeading}
				\iftotaltables\listoftables\insert@lot@after\fi
				\iftotalfigures\listoffigures\insert@lof@after\fi
			}
		}{
			\ifnumcomp{\value{figuresandtables}}{=}{0}{}
			{
				\ifboolexpr{test{\ifdefempty{\insert@lot@before}} and test{\ifdefempty{\insert@lof@before}}}{}
				{\setchapterpreamble[u]{\insert@lof@before\insert@lot@before}}
				\addchap{\currentChapterHeading}
				\iftotalfigures\listoffigures\insert@lof@after\fi
				\iftotaltables\listoftables\insert@lot@after\fi
			}
		}
		\insert@hook@lists@compact
	}{
		\iftoggle{option@layout@listof@tablesfirst}
		{
			\iftotaltables\ifdefempty{\insert@lot@before}{}{\setchapterpreamble[u]{\insert@lot@before}}\listoftables\insert@lot@after\fi
			\iftotalfigures\ifdefempty{\insert@lof@before}{}{\setchapterpreamble[u]{\insert@lof@before}}\listoffigures\insert@lof@after\fi
		}{
			\iftotalfigures\ifdefempty{\insert@lof@before}{}{\setchapterpreamble[u]{\insert@lof@before}}\listoffigures\insert@lof@after\fi
			\iftotaltables\ifdefempty{\insert@lot@before}{}{\setchapterpreamble[u]{\insert@lot@before}}\listoftables\insert@lot@after\fi
		}
		\insert@hook@lists@regular
	}
	\insert@hook@lists

	\begingroup%
	    \iftoggle{option@layout@listof@compact}
	    {
	        \setglossarysection{section=section}
	        \glstocfalse
	    }{}
	
		\setglossarystyle{hsmw-acronym}%
		%\clearpage
        \printglossary[type=\acronymtype,title=\acronymname]%\printacronyms
		\setglossarystyle{hsmw-symbols}%
		\printglossary[type=symbols,title=\symbolname]%\printsymbols
		\iftoggle{option@layout@glossary@front}
		{%
			\setglossarystyle{list}%
			\printglossary%
		}{}
	\endgroup%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Statement of authorship

% NewDocumentCommand is robust and therefore \StatementOfAuthorshipName can not be expanded properly in e.g. PDF Bookmarks... use explicit \NewExpandableDocumentCommand for this case
\NewExpandableDocumentCommand{\StatementOfAuthorshipName}{}
{%
	\iftoggle{option@layout@paper}
	{\GetMultiLanguageLabel{statementAuthorshipTitlePaper}}
	{\GetMultiLanguageLabel{statementAuthorshipTitleOath}}%
}
\NewDocumentCommand{\StatementOfAuthorshipText}{}
{%
	\iftoggle{option@layout@paper}
	{%
		\ifnumgreater{\value{author@amount}}{1}
		{\GetMultiLanguageLabel{statementAuthorshipMultiplePaper}}
		{\GetMultiLanguageLabel{statementAuthorshipSinglePaper}}%
	}{%
		\ifnumgreater{\value{author@amount}}{1}
		{\GetMultiLanguageLabel{statementAuthorshipMultipleOath}}
		{\GetMultiLanguageLabel{statementAuthorshipSingleOath}}%
	}%
}
\NewDocumentCommand{\StatementOfAuthorshipSignature}{}
{
	\begingroup
	\def\and{, }
	\renewcommand{\@author@format}[7]{{\ifstrempty{##2}{}{##2 }##3 ##4\ifstrempty{##5}{}{, ##5}}/{##6}/{##7}}% salutation*, [title], prename, surname, [acad], <signaturefilepath>, <signatureShift>
	
	% Prevents document error in for-loop if no authors are specified
	\ifnumequal{\value{author@amount}}{0}
	{\def\forauthor{}}
	{\edef\forauthor{\@author}}
	
	\parbox[t]{.4\linewidth}
	{
		\rule{0pt}{\signatureHeight}%
		\@location,%
		\begingroup
			\DTMsetdatestyle{hsmwmonthstyle}
			\@date
		\endgroup
		\\[-.75\baselineskip]
		\rule{\linewidth}{\arrayrulewidth}\\
		\GetMultiLanguageLabel{location}, \GetMultiLanguageLabel{date}
	}
	\hfill
	\parbox[t]{.55\linewidth}
	{
		\foreach \name/\sig/\shift in \forauthor
		{
			\ifdefempty{\shift}{\def\shift{0pt}}{}
			\rule{0pt}{\signatureHeight}%
			\ifdefempty{\sig}{}{\IfFileExists{\sig}{\raisebox{-\shift}[\ht\strutbox][\dp\strutbox]{\includegraphics[height=\signatureHeight, width=\linewidth, keepaspectratio]{\sig}}}{\PrintWarning*{Signature file '\sig' not found}}}
			\\[-.75\baselineskip]
			\rule{\linewidth}{\arrayrulewidth}\\
			\name\\
			
		}
	}
	\endgroup
}
\NewDocumentCommand{\MakeStatementOfAuthorship}{}
{
	\addchap{\StatementOfAuthorshipName} % addchap = like chapter, but without number (still into toc and header); starred: clears header title (no leakage of following pages)
	\StatementOfAuthorshipText
	
	\StatementOfAuthorshipSignature
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Add Document Hooks
\iftoggle{option@layout@draft}
{}{
	\makeglossaries % Glossary and Acronyms
	\makeindex[intoc]
	
	\AddToHook{begindocument/before}
	{
		\begingroup
			%Redefine \and from author and newlines from title/subtitle to prevent hyperlink macro leakage and warnings
			\def\and{, }
			\def\\{\ }
			\def\newline{\ }
			\renewcommand{\@author@format}[7]{#3 #4}

			% Use hyperref's PDF-string conversion so formatting commands (e.g., \textit) in title/author don't break the PDF metadata setup.
			\pdfstringdef\pdftitle{\@title}
			\pdfstringdef\pdfauthor{\@author}
			\pdfstringdef\pdfsubtitle{\@subtitle}
			
			\hypersetup%
			{
				pdftitle = {\pdftitle},
				pdfauthor = {\pdfauthor},
				pdfsubject = {\pdfsubtitle},
				pdfkeywords = {LaTeX-Template Hochschule Mittweida (https://git.hs-mittweida.de/hsmw-latex/hsmw-latex)},
			}
		\endgroup
		\insert@preamble
	}
	\AddToHook{begindocument/end}
	{%
		\maketitle%
	}
	\AddToHook{enddocument}
	{%
		\backmatter%If not called by appendix, do it here (sanity check within \backmatter)
		% Glossaries (makeindex or xindy)
		% glo -> gls
		
		%%% Checking file extensions and only processing needed printing works nice in local distribution but breaks automatic overleaf processing
		%\IfFileExists{\jobname.gls}{
%		\printglossaries
		%TODO: If there is no glossary but acronyms this call sometimes inserts an empty page
		\iftoggle{option@layout@glossary@front}{}
		{%
			\setglossarystyle{list}%
			\printglossary%
		}%
		%}{\IfFileExists{\jobname.glo}{\ClassWarningNoLine{\currentClassName}{You are using glossary items but haven't called 'makeglossaries \jobname.glo' yet...}}{}}%

		\begingroup
		\insert@bibliography@before
		\insert@bibliography
		\endgroup
			
		%\IfFileExists{\jobname.ind}{
		\printindex
		%}{\IfFileExists{\jobname.idx}{\ClassWarningNoLine{\currentClassName}{You are using index items but haven't called 'makeindex \jobname.idx' yet...}}{}}%

		\insert@between@index@soa

		\iftoggle{option@layout@authorship@show}{\MakeStatementOfAuthorship}{}
		
		\insert@lastpage
	}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Language Support

% Utility for configuring multiple languages at once
\NewDocumentCommand{\SetMultiLanguageLabel}{sm+m+m}% override*, label, english, german
{
	% Prevent overwrite, unless starred version
	\IfBooleanF{#1}
	{
		% Check if label with this name is already defined and issue error
		\ifcsdef{label@#2}{\ClassError{\currentClassName}{Already defined label '#2'}{Rename Label}}{}
	}

	% Default value is warning message
	\expandafter\def\csname label@#2\endcsname{\PrintWarning*{Label '#2' is not yet translated}}
	% Add translations here
	\appto\captionsenglish{\expandafter\expandafter\def\csname label@#2\endcsname{#3}} % English
	\appto\captionsngerman{\expandafter\expandafter\def\csname label@#2\endcsname{#4}} % German
}
\NewDocumentCommand{\SetLanguageLabel}{smm+m}% override*, label, language, value
{
	% Prevent overwrite, unless starred version
	\IfBooleanF{#1}
	{
		% Check if label with this name is already defined and issue error
		\ifcsdef{label@#2}{\ClassError{\currentClassName}{Already defined label '#2'}{Rename Label}}{}
	}
	
	% Default value is warning message
	\expandafter\def\csname label@#2\endcsname{\PrintWarning*{Label '#2' is not yet translated}}
	% Add translation here
	\expandafter\appto\csname captions#3\endcsname{\expandafter\expandafter\def\csname label@#2\endcsname{#4}}
}
% Retrieve a previously configured label
\NewExpandableDocumentCommand{\GetMultiLanguageLabel}{m}
{%
	% Check if label with this name is defined and issue error
	\IfMultiLanguageLabel{#1}
	{\csname label@#1\endcsname}
	{\ClassError{\currentClassName}{Label '#1' is not defined but used}{Define Label}}%
}
% Check if requested label is defined and process true/false regarding
\newcommand{\IfMultiLanguageLabel}[3]{\ifcsdef{label@#1}{#2}{#3}}

% Configure used labels
\SetMultiLanguageLabel{courseofstudy}{Course of Study}{Studiengang}
\SetMultiLanguageLabel{seminargroup}{Seminar Group}{Seminargruppe}
%RÖBBE
\SetMultiLanguageLabel{betreuer}{Additional Supervisor(s)}{Weitere Betreuer}

\SetMultiLanguageLabel{module}{Module}{Modul}
\SetMultiLanguageLabel{faculty}{Faculty of}{Fakultät}
\SetMultiLanguageLabel{author}{Author\ifnumgreater{\value{author@amount}}{1}{s}{}}{Autor\ifnumgreater{\value{author@amount}}{1}{\iftoggle{author@gender}{innen}{en}}{\iftoggle{author@gender}{in}{}}}
\SetMultiLanguageLabel{supervisor}{Supervisor}{Prüfer\ifnumgreater{\value{examiner@amount}}{1}{\iftoggle{examiner@genders}{innen}{}}{\iftoggle{examiner@genders}{in}{}}}
\SetMultiLanguageLabel{examiner@1}{First Examiner}{Erstprüfer\ifnumgreater{\value{examiner@amount}}{0}{\iftoggle{examiner@gender@1}{in}{}}{}}
\SetMultiLanguageLabel{examiner@2}{Second Examiner}{Zweitprüfer\ifnumgreater{\value{examiner@amount}}{1}{\iftoggle{examiner@gender@2}{in}{}}{}}
\SetMultiLanguageLabel{submission}{Submission}{Einreichung}
\SetMultiLanguageLabel{defense}{Defense/Evaluation}{Verteidigung/Bewertung}
\SetMultiLanguageLabel{bibliographicdescription}{Bibliographic Description}{Bibliografische Beschreibung}
\SetMultiLanguageLabel{salutationmale}{Mr.}{Herr}
\SetMultiLanguageLabel{salutationfemale}{Ms.}{Frau}
\SetMultiLanguageLabel{dedicationname}{Acknowledgment}{Danksagung}
\SetMultiLanguageLabel{abstract}{Abstract}{Referat}
\SetMultiLanguageLabel{email}{E-Mail}{E-Mail}
\SetMultiLanguageLabel{listoffiguresandtables}{List of Figures and Tables}{Abbildungs- und Tabellenverzeichnis}
\SetMultiLanguageLabel{listoftablesandfigures}{List of Tables and Figures}{Tabellen- und Abbildungsverzeichnis}
\SetMultiLanguageLabel{additionallists}{Additional Lists}{Ergänzende Verzeichnisse}
\SetMultiLanguageLabel{location}{Location}{Ort}
\SetMultiLanguageLabel{date}{Date}{Datum}

\SetMultiLanguageLabel{statementAuthorshipTitlePaper}{Declaration of Authorship}{Selbstständigkeitserklärung}% Declaration of Authorship 
\SetMultiLanguageLabel{statementAuthorshipTitleOath}{Statutory Declaration in Lieu of an Oath}{Eidesstattliche Erklärung}% Statutory Declaration % Statutory Declaration in Lieu of an Oath % Declaration of Academic Integrity 
\SetMultiLanguageLabel{statementAuthorshipSinglePaper}
{I do hereby declare that I have composed the presented work independently on my own and without any other resources than the ones given.\par
All thoughts taken directly or indirectly from external sources are correctly acknowledged.\par
This work has neither been previously submitted to another authority nor has it been published yet.\par}
{Hiermit erkläre ich, dass ich die vorliegende Arbeit selbstständig und nur unter Verwendung der angegebenen Quellen und Hilfsmittel angefertigt habe.\par
Sämtliche Stellen der Arbeit, die im Wortlaut oder dem Sinn nach Publikationen oder Vorträgen anderer Autoren entnommen sind, habe ich als solche kenntlich gemacht.\par
Diese Arbeit wurde in gleicher oder ähnlicher Form noch keiner anderen Prüfungsbehörde vorgelegt oder anderweitig veröffentlicht.\par}
\SetMultiLanguageLabel{statementAuthorshipMultiplePaper}
{We do hereby declare that we have composed the presented work independently on our own and without any other resources than the ones given.\par
All thoughts taken directly or indirectly from external sources are correctly acknowledged.\par
This work has neither been previously submitted to another authority nor has it been published yet.\par}
{Hiermit erklären wir, dass wir die vorliegende Arbeit selbstständig und nur unter Verwendung der angegebenen Quellen und Hilfsmittel angefertigt haben.\par
Sämtliche Stellen der Arbeit, die im Wortlaut oder dem Sinn nach Publikationen oder Vorträgen anderer Autoren entnommen sind, haben wir als solche kenntlich gemacht.\par
Diese Arbeit wurde in gleicher oder ähnlicher Form noch keiner anderen Prüfungsbehörde vorgelegt oder anderweitig veröffentlicht.\par}
\SetMultiLanguageLabel{statementAuthorshipSingleOath}
{I -- {\@author} -- do hereby declare in lieu of an oath that I have composed the presented work independently on my own and without any other resources than the ones given.\par
All thoughts taken directly or indirectly from external sources are correctly acknowledged.\par
This work has neither been previously submitted to another authority nor has it been published yet.\par}
{Hiermit versichere ich -- {\@author} -- an Eides statt, dass ich die vorliegende Arbeit selbstständig und nur unter Verwendung der angegebenen Quellen und Hilfsmittel angefertigt habe.\par
Sämtliche Stellen der Arbeit, die im Wortlaut oder dem Sinn nach Publikationen oder Vorträgen anderer Autoren entnommen sind, habe ich als solche kenntlich gemacht.\par
Diese Arbeit wurde in gleicher oder ähnlicher Form noch keiner anderen Prüfungsbehörde vorgelegt oder anderweitig veröffentlicht.\par}
\SetMultiLanguageLabel{statementAuthorshipMultipleOath}
{We -- {\def\and{, }\@author} -- do hereby declare in lieu of an oath that we have composed the presented work independently on our own and without any other resources than the ones given.\par
All thoughts taken directly or indirectly from external sources are correctly acknowledged.\par
This work has neither been previously submitted to another authority nor has it been published yet.\par}
{Hiermit versichern wir -- {\def\and{, }\@author} -- an Eides statt, dass wir die vorliegende Arbeit selbstständig und nur unter Verwendung der angegebenen Quellen und Hilfsmittel angefertigt haben.\par
Sämtliche Stellen der Arbeit, die im Wortlaut oder dem Sinn nach Publikationen oder Vorträgen anderer Autoren entnommen sind, haben wir als solche kenntlich gemacht.\par
Diese Arbeit wurde in gleicher oder ähnlicher Form noch keiner anderen Prüfungsbehörde vorgelegt oder anderweitig veröffentlicht.\par}

\SetMultiLanguageLabel{nda@title}{Confidential Clause}{Sperrvermerk}
\SetMultiLanguageLabel{nda@text}{This work is based on internal, confidential data and informations of the following enterprise: \textit{\@nondisclosureagreement@party}. Therefore this work may only be available to the specified supervisors and authorized members of the board of examiners. Any publication and duplication of this document -- even in part -- is prohibited. An inspection of this work by third parties requires the expressed admission of the author and the company.}{Die vorliegende Arbeit basiert auf internen, vertraulichen Daten und Informationen des Unternehmens \textit{\@nondisclosureagreement@party}. Die Arbeit darf daher nur vom Erst- und Zweitgutachter, sowie berechtigten Mitgliedern des Prüfungsausschusses eingesehen werden. Eine Vervielfältigung und Veröffentlichung der Arbeit ist -- auch in Auszügen -- nicht erlaubt. Dritten darf diese Arbeit nur mit der ausdrücklichen Genehmigung des Verfassers und Unternehmens zugänglich gemacht werden.}

\SetMultiLanguageLabel{thesis@name@paper}{Term Paper}{Belegarbeit}
%RÖBBE
\SetMultiLanguageLabel{thesis@name@protokoll}{Protocol}{Protokoll}
\SetMultiLanguageLabel{thesis@name@diploma}{Diploma Thesis}{Diplomarbeit}
\SetMultiLanguageLabel{thesis@name@bachelor}{Bachelor Thesis}{Bachelorarbeit}
\SetMultiLanguageLabel{thesis@name@master}{Master Thesis}{Masterarbeit}

\SetMultiLanguageLabel{faculty@name@inw}{Engineering Sciences}{Ingenieurwissenschaften}
\SetMultiLanguageLabel{faculty@name@cb}{Applied Computer Sciences and Biosciences}{Angewandte Computer- und Biowissenschaften}
\SetMultiLanguageLabel{faculty@name@wi}{Industrial Engineering}{Wirtschaftsingenieurwesen}
\SetMultiLanguageLabel{faculty@name@sw}{Social Sciences}{Soziale Arbeit}
\SetMultiLanguageLabel{faculty@name@me}{Media Sciences}{Medien}



%%% Finetuning exitsing labels
% Sources: https://github.com/latex3/babel/blob/main/locale/de/babel-de.ini
\appto\captionsngerman{\renewcommand*{\bibname}{Literaturverzeichnis}} % Bibliografie (\refname)
\appto\captionsngerman{\renewcommand*{\acronymname}{Abkürzungsverzeichnis}} % Symbolverzeichnis (\nomname)
\appto\captionsngerman{\renewcommand*{\symbolname}{Symbolverzeichnis}} % Symbolverzeichnis
\appto\captionsngerman{\renewcommand*{\indexname}{Stichwortverzeichnis}} % Index
%\appto\captionsngerman{\renewcommand{\prefacename}{Vorwort}}

\providecommand{\lstlistingname}{}% Fallback if Listings is not loaded or unknown
\providecommand{\lstlistlistingname}{}% Fallback if Listings is not loaded or unknown
\appto\captionsngerman{\renewcommand*{\lstlistingname}{Quelltext}}
\appto\captionsngerman{\renewcommand*{\lstlistlistingname}{Quelltextverzeichnis}}
\crefname{lstlisting}{\lstlistingname}{\lstlistingname{}e}%Add lstlisting as cref format (\Cref is automatically set)

%%%CAUTION: this is a workaround hack to uniformly handle \bibname with biblatex and babel
\AddToHook{begindocument}
{
	%biblatex redefines bibname to internal bibliography string (https://github.com/plk/biblatex/blob/dev/tex/latex/biblatex/biblatex.sty#L5576)
	%internal string is hardcoded in language file (https://github.com/plk/biblatex/blob/dev/tex/latex/biblatex/lbx/german.lbx#L96)
	%use current bibname as placeholder to override internal string in biblatex (which will be used as bibname after loading)
	\let\bibnameold\bibname
	\@ifpackageloaded{biblatex}
	{
		\DefineBibliographyStrings{german}{
			bibliography = {\bibnameold},
			references = {\bibnameold},
		}
	}{}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Corporate design style elements as tikz paths (for easy coloring)

%\RequirePackage{xcolor}
%\RequirePackage{tikz}
%\usetikzlibrary{calc}

\newlength{\lw@target}% Temporary length for scaling size
\newlength{\luw@default}% Default \luw value

\newlength{\luw}% Logo Unit Width
\newlength{\luws}% Logo Unit Width Space
\newlength{\luh}% Logo Unit Height Space
\newlength{\luhx}% Logo Unit Height Extended
\newlength{\luhs}% Logo Unit Height Space

\setlength{\luw@default}{1.000 cm}
\setlength{\luw}{\luw@default}

\NewDocumentCommand{\logoUpdateLengths}{O{1}}
{
	\setlength{\luw}{#1\luw@default}
	\setlength{\luh}{1.25334\luw}
	\setlength{\luhx}{1.8511\luh}
	\setlength{\luws}{.2\luw}
	\setlength{\luhs}{.1064\luh}
}
% Initially update all lengths to default values
\logoUpdateLengths

\NewDocumentCommand{\logoScaleToWidth}{ssm}%withsavespace*, with background**, width
{
	\setlength{\luw}{\luw@default}
	\setlength{\lw@target}{#3}
	
	\pgfmathsetmacro{\luw@factor}{10*(\luw+\luws)}
	\IfBooleanTF{#1}{\pgfmathsetmacro{\luw@factor}{\luw@factor+2\luw}}{}
	\IfBooleanTF{#2}{\pgfmathsetmacro{\luw@factor}{\luw@factor+4\luw+4\luws}}{}
	\pgfmathsetmacro{\luw@factor}{\lw@target/\luw@factor}
	
	\logoUpdateLengths[\luw@factor]
}
\NewDocumentCommand{\logoDesignBackgroundPath}{sD(){0,0}mm}% bottom*, (offsetcoordinates), color
{
	\coordinate (shiftCoordinate) at (#2);
	
	%TODO: Corporate Design construction manual does not reflect used style elements in word templates (slightly differnt borders and spacings): Feedback Furchner needed!
	\IfBooleanTF{#1}
	{
		\begin{scope}[x=.1\luw, y=.1\luw, shift={(shiftCoordinate)}, local bounding box=#3]
			\fill[#4]
			(0,0)
			to ++(188, 0)
			to ++(0, 60)
			.. controls ++(-65.3422, 0) and ++(50.9104, 10.4723) .. ++(-177.0798, -16.5589)
			.. controls ++(-6.36, -1.309) and ++(0, 6.4935) .. ++(-10.9201, -13.4004)
			to ++(0, -30.0341)		
			;
		\end{scope}
	}{
		\begin{scope}[x=.1\luw, y=.1\luw, shift={(shiftCoordinate)}, local bounding box=#3]
			\fill[#4]
			(0,0)
			to ++(0, -80.2718)		
			.. controls ++(0, -8.6186) and ++(-8.4549, -1.6664) .. ++(16.3221, -13.4133)
			.. controls ++(49.7887, 9.8049) and ++(-63.0449, 0) .. ++(171.6779, 15.4716)
			to ++(0, 78.2138)
			to ++(-188, 0)
			;
		\end{scope}
	}
}
\NewDocumentCommand{\logoDesignMarkUnitPath}{ssD(){0,0}m} % rotate*, stretch**, (offsetcoordinates), color
{
	\IfBooleanTF{#1}
	{
		\coordinate (shiftCoordinate) at (\luw, \luh);
		\def\rotateAngle{180}
	}{
		\coordinate (shiftCoordinate) at (0,0);
		\def\rotateAngle{0}
	}
	\IfBooleanTF{#2}% The stretching factor for the middle pillar of the logo
	{
		\pgfmathparse{1+((\luhx - \luh)/(0.871\luh))}% 0.871\luh = Effective length of the center piece of a side without the rounded parts
		\edef\stetchFactor{\pgfmathresult}
	}
	{\def\stetchFactor{1}}
	
	\coordinate (shiftCoordinate) at ($(shiftCoordinate)+(#3)$);
	
	\begin{scope}[x=.1\luw, y=.1\luw, shift={(shiftCoordinate)}, rotate={\rotateAngle}]
		\fill[#4]
		(0,0)
		++(-0.30573, -0.01345) % Nearest bounding box corner
		++(\luw, \luh)
		.. controls ++(-1.2338, -0.4503) and ++(1.8287, 0) .. ++(-4.6945, -0.8616)
		.. controls ++(-1.8284, 0) and ++(1.2342, -0.4503) .. ++(-4.6941, 0.8616)
		.. controls ++(-0.1521, 0.0552) and ++(0, 0.1776) .. ++(-0.3057, -0.2456)
		to ++(0, -10.9037*\stetchFactor)
		.. controls ++(0, -0.1033) and ++(-0.086, 0.0409) .. ++(0.1382, -0.237)
		.. controls ++(0.9867, -0.4657) and ++(-2.0939, 0) .. ++(4.8616, -1.1335)
		.. controls ++(2.0759, 0) and ++(-0.9931, -0.4665) .. ++(4.862, 1.138)
		.. controls ++(0.086, 0.0402) and ++(0, -0.1033) .. ++(0.1382, 0.2363)
		to ++(0, 10.9*\stetchFactor)
		.. controls ++(0, 0.1777) and ++(0.1517, 0.0556) .. ++(-0.3057, 0.2456)
		;
	\end{scope}	
}
\NewDocumentCommand{\logoDesignMarkPath}{D(){0,0}mm}% (offsetcoordinates), color
{
	\begin{scope}[local bounding box=#2]
		\logoDesignMarkUnitPath{#3}
		\logoDesignMarkUnitPath(0, \luh+\luhs){#3}
		\logoDesignMarkUnitPath*(\luw+\luws, 0){#3}
		\logoDesignMarkUnitPath**(\luw+\luws, \luh+\luhs){#3}
		\logoDesignMarkUnitPath*(2\luw+2\luws, 0){#3}
		\logoDesignMarkUnitPath*(2\luw+2\luws, \luh+\luhs){#3}
	\end{scope}
}
\NewDocumentCommand{\logoWordMarkPath}{D(){0,0}mm}% (offsetcoordinates), color
{
	\coordinate (shiftCoordinate) at (#1);
	\begin{scope}[x=.1\luw, y=.1\luw, shift={(shiftCoordinate)}, local bounding box=#2]
		\fill[#3]
		(0, 0)
		++(2.333, -20.990)
		to ++(0, -2.3413) .. controls ++(0, -0.5994) and ++(0.5719, 0) .. ++(-0.8571, -0.9012) .. controls ++(-0.2935, 0) and ++(0.1433, -0.1447) .. ++(-0.6546, 0.2191) .. controls ++(-0.1419, 0.1461) and ++(0, -0.3073) .. ++(-0.2136, 0.678) to ++(0, 2.3454) to ++(-0.6077, 0) to ++(0, -2.3895) .. controls ++(0, -0.4258) and ++(-0.2563, 0.2439) .. ++(0.3831, -1.0046) .. controls ++(0.2549, -0.2425) and ++(-0.4589, 0) .. ++(1.0721, -0.3652) .. controls ++(0.3101, 0) and ++(-0.2219, -0.1089) .. ++(0.7979, 0.1654) .. controls ++(0.2233, 0.1116) and ++(-0.1171, -0.2053) .. ++(0.5099, 0.4754) .. controls ++(0.1185, 0.2053) and ++(0, -0.2742) .. ++(0.1764, 0.7193) to ++(0, 2.3992) to ++(-0.6063, 0)
		++(3.9384, -1.8796) .. controls ++(0, 0.6849) and ++(0.6739, 0) .. ++(-1.0101, 1.028) .. controls ++(-0.1902, 0) and ++(0.1543, 0.0731) .. ++(-0.5168, -0.1103) .. controls ++(-0.1557, -0.073) and ++(0.0854, 0.1337) .. ++(-0.3611, -0.3087) to ++(-0.0303, 0) to ++(-0.0841, 0.3679) to ++(-0.4658, 0) to ++(0, -2.8057) to ++(0.5953, 0) to ++(0, 1.3973) .. controls ++(0, 0.35) and ++(-0.1171, -0.1488) .. ++(0.175, 0.7483) .. controls ++(0.1171, 0.1488) and ++(-0.2508, 0) .. ++(0.5526, 0.2232) .. controls ++(0.1902, 0) and ++(-0.0868, 0.1062) .. ++(0.4148, -0.1599) .. controls ++(0.0882, -0.1061) and ++(0, 0.2164) .. ++(0.1309, -0.4837) to ++(0, -1.7253) to ++(0.5995, 0) to ++(0, 1.8287)
		++(1.3987, 0.977) to ++(-0.5967, 0) to ++(0, -2.8057) to ++(0.5967, 0) to ++(0, 2.8057) ++(-0.5443, 0.503) .. controls ++(0.0593, -0.0579) and ++(-0.1089, 0) .. ++(0.2508, -0.0882) .. controls ++(0.1047, 0) and ++(-0.0579, -0.0579) .. ++(0.2439, 0.0882) .. controls ++(0.0593, 0.0579) and ++(0, -0.102) .. ++(0.0882, 0.2398) .. controls ++(0, 0.1061) and ++(0.0593, -0.0579) .. ++(-0.0882, 0.2467) .. controls ++(-0.0579, 0.0565) and ++(0.1047, 0) .. ++(-0.2439, 0.0854) .. controls ++(-0.1089, 0) and ++(0.0592, 0.0565) .. ++(-0.2508, -0.0854) .. controls ++(-0.0579, -0.0579) and ++(0, 0.1061) .. ++(-0.0868, -0.2467) .. controls ++(0, -0.102) and ++(-0.0579, 0.0579) .. ++(0.0868, -0.2398)
		++(3.7992, -0.5030) to ++(-0.6339, 0) to ++(-0.5705, -1.6316) .. controls ++(-0.1033, -0.3211) and ++(0.0152, 0.1213) .. ++(-0.1778, -0.6642) to ++(-0.0207, 0) .. controls ++(-0.0193, 0.1695) and ++(0.0979, -0.2729) .. ++(-0.1764, 0.6642) to ++(-0.5719, 1.6316) to ++(-0.6284, 0) to ++(1.0652, -2.8057) to ++(0.644, 0) to ++(1.071, 2.8057)
		++(2.122, -2.814) .. controls ++(0.1488, 0.0289) and ++(-0.1461, -0.0688) .. ++(0.441, 0.1474) to ++(0, 0.4851) .. controls ++(-0.164, -0.073) and ++(0.1433, 0.0317) .. ++(-0.4603, -0.1571) .. controls ++(-0.1433, -0.0303) and ++(0.1654, 0) .. ++(-0.463, -0.0455) .. controls ++(-0.2522, 0) and ++(0.1378, -0.1461) .. ++(-0.5857, 0.2191) .. controls ++(-0.1392, 0.1461) and ++(0.0083, -0.2729) .. ++(-0.2205, 0.627) to ++(1.8686, 0) to ++(0, 0.3225) .. controls ++(0, 0.3941) and ++(0.215, -0.2246) .. ++(-0.3225, 0.9288) .. controls ++(-0.2136, 0.2246) and ++(0.3707, 0) .. ++(-0.8778, 0.3376) .. controls ++(-0.3982, 0) and ++(0.2287, 0.2618) .. ++(-0.9412, -0.3941) .. controls ++(-0.2274, -0.2618) and ++(0, 0.4589) .. ++(-0.3417, -1.0804) .. controls ++(0, -0.4465) and ++(-0.2453, 0.2549) .. ++(0.3693, -1.0514) .. controls ++(0.2467, -0.2536) and ++(-0.4368, 0) .. ++(1.0239, -0.3817) .. controls ++(0.1915, 0) and ++(-0.1502, -0.0275) .. ++(0.5099, 0.0427) ++(-0.1723, 2.2338) .. controls ++(0.1075, -0.1199) and ++(-0.0041, 0.2315) .. ++(0.1667, -0.5264) to ++(-1.2733, 0) .. controls ++(0.0221, 0.2301) and ++(-0.1143, -0.1185) .. ++(0.204, 0.525) .. controls ++(0.1144, 0.1199) and ++(-0.1888, 0) .. ++(0.4548, 0.1805) .. controls ++(0.1902, 0) and ++(-0.1089, 0.1185) .. ++(0.4479, -0.1791)
		++(2.3799, 0.4837) .. controls ++(-0.1488, -0.0992) and ++(0.0923, 0.1667) .. ++(-0.3638, -0.3983) to ++(-0.0303, 0) to ++(-0.0786, 0.4947) to ++(-0.4672, 0) to ++(0, -2.8057) to ++(0.5967, 0) to ++(0, 1.4662) .. controls ++(0, 0.2481) and ++(-0.1475, -0.1557) .. ++(0.2205, 0.6063) .. controls ++(0.1488, 0.1543) and ++(-0.2384, 0) .. ++(0.5802, 0.2329) .. controls ++(0.0909, 0) and ++(-0.0854, 0.0203) .. ++(0.2646, -0.0303) to ++(0.0579, 0.5554) .. controls ++(-0.0772, 0.0165) and ++(0.1199, 0) .. ++(-0.2963, 0.0262) .. controls ++(-0.1723, 0) and ++(0.1502, 0.0978) .. ++(-0.4837, -0.1474)
		++(3.1722, -1.5613) .. controls ++(-0.051, 0.0978) and ++(0.1034, -0.073) .. ++(-0.2329, 0.2563) .. controls ++(-0.1047, 0.0758) and ++(0.2315, -0.0896) .. ++(-0.5057, 0.2467) .. controls ++(-0.2742, 0.1061) and ++(0.0827, -0.0606) .. ++(-0.5361, 0.2508) .. controls ++(-0.0827, 0.062) and ++(0, -0.0882) .. ++(-0.1226, 0.2246) .. controls ++(0, 0.1791) and ++(-0.3156, 0) .. ++(0.4713, 0.2673) .. controls ++(0.2067, 0) and ++(-0.3032, 0.1254) .. ++(0.7634, -0.1874) to ++(0.1929, 0.4492) .. controls ++(-0.2949, 0.1337) and ++(0.3294, 0) .. ++(-0.9357, 0.2012) .. controls ++(-0.3335, 0) and ++(0.1943, 0.1323) .. ++(-0.791, -0.1998) .. controls ++(-0.1929, -0.1337) and ++(0, 0.2398) .. ++(-0.2894, -0.5595) .. controls ++(0, -0.1998) and ++(-0.1144, 0.1254) .. ++(0.1709, -0.4864) .. controls ++(0.1144, -0.1254) and ++(-0.3238, 0.124) .. ++(0.6559, -0.3748) .. controls ++(0.1654, -0.0661) and ++(-0.0923, 0.051) .. ++(0.3872, -0.1736) .. controls ++(0.0923, -0.0496) and ++(-0.0413, 0.0469) .. ++(0.2012, -0.1461) .. controls ++(0.04, -0.0482) and ++(0, 0.0703) .. ++(0.0606, -0.1778) .. controls ++(0, -0.2219) and ++(0.3679, 0) .. ++(-0.5512, -0.3335) .. controls ++(-0.2839, 0) and ++(0.3293, -0.1529) .. ++(-0.9205, 0.2301) to ++(0, -0.5154) .. controls ++(0.2274, -0.113) and ++(-0.3735, 0) .. ++(0.9012, -0.1709) .. controls ++(0.3707, 0) and ++(-0.1998, -0.1461) .. ++(0.8571, 0.2191) .. controls ++(0.1998, 0.1461) and ++(0, -0.2742) .. ++(0.299, 0.6311) .. controls ++(0, 0.135) and ++(0.0496, -0.0978) .. ++(-0.0758, 0.3486) 
		++(1.3078, 1.6578) to ++(-0.5967, 0) to ++(0, -2.8057) to ++(0.5967, 0) to ++(0, 2.8057) ++(-0.5443, 0.503) .. controls ++(0.0593, -0.0579) and ++(-0.1089, 0) .. ++(0.2508, -0.0882) .. controls ++(0.1047, 0) and ++(-0.0579, -0.0579) .. ++(0.2439, 0.0882) .. controls ++(0.0579, 0.0579) and ++(0, -0.102) .. ++(0.0868, 0.2398) .. controls ++(0, 0.1061) and ++(0.0579, -0.0579) .. ++(-0.0868, 0.2467) .. controls ++(-0.0579, 0.0565) and ++(0.1047, 0) .. ++(-0.2439, 0.0854) .. controls ++(-0.1089, 0) and ++(0.0593, 0.0565) .. ++(-0.2508, -0.0854) .. controls ++(-0.0579, -0.0579) and ++(0, 0.1061) .. ++(-0.0868, -0.2467) .. controls ++(0, -0.102) and ++(-0.0579, 0.0579) .. ++(0.0868, -0.2398)
		++(2.1594, -2.774) .. controls ++(-0.073, 0.0675) and ++(0, -0.1447) .. ++(-0.1089, 0.3183) to ++(0, 1.5007) to ++(0.7993, 0) to ++(0, 0.452) to ++(-0.7993, 0) to ++(0, 0.623) to ++(-0.3679, 0) to ++(-0.2026, -0.5926) to ++(-0.4107, -0.2177) to ++(0, -0.2646) to ++(0.3831, 0) to ++(0, -1.5117) .. controls ++(0, -0.5953) and ++(-0.565, 0) .. ++(0.8475, -0.893) .. controls ++(0.1116, 0) and ++(-0.1033, -0.0179) .. ++(0.3225, 0.0289) .. controls ++(0.1047, 0.0193) and ++(-0.0661, -0.0289) .. ++(0.2549, 0.073) to ++(0, 0.4492) .. controls ++(-0.1447, -0.0469) and ++(0.1461, 0) .. ++(-0.4355, -0.0689) .. controls ++(-0.1171, 0) and ++(0.0703, -0.0703) .. ++(-0.2825, 0.1034)
		++(2.0547, -0.7979)	.. controls ++(-0.1158, -0.3335) and ++(0.288, 0) .. ++(-0.6063, -0.5002) .. controls ++(-0.1144, 0) and ++(0.0896, -0.0203) .. ++(-0.3059, 0.0303) to ++(0, -0.4713) .. controls ++(0.1254, -0.0289) and ++(-0.1323, 0) .. ++(0.3859, -0.0441) .. controls ++(0.5085, 0) and ++(-0.2177, -0.5829) .. ++(1.09, 0.8751) to ++(1.2003, 3.1791) to ++(-0.6435, 0) .. controls ++(-0.39, -1.1286) and ++(0.04, 0.1323) .. ++(-0.6449, -1.8907) .. controls ++(-0.0413, -0.1323) and ++(0.0152, 0.0923) .. ++(-0.0841, -0.339) to ++(-0.0207, 0) .. controls ++(-0.0289, 0.1998) and ++(0.0868, -0.226) .. ++(-0.1723, 0.6394) to ++(-0.5705, 1.5903) to ++(-0.6491, 0) to ++(1.127, -2.806) to ++(-0.105, -0.265)
		++(5.539, 2.729) .. controls ++(-0.237, 0.2618) and ++(0.4065, 0) .. ++(-0.9646, 0.3927) .. controls ++(-0.4231, 0) and ++(0.2329, 0.2549) .. ++(-0.9853, -0.3831) .. controls ++(-0.2329, -0.2563) and ++(0, 0.4561) .. ++(-0.35, -1.0666) .. controls ++(0, -0.2921) and ++(-0.1075, 0.2219) .. ++(0.1612, -0.7703) .. controls ++(0.1089, -0.2219) and ++(-0.2012, 0.1185) .. ++(0.4644, -0.5099) .. controls ++(0.2012, -0.1185) and ++(-0.2618, 0) .. ++(0.6959, -0.1778) .. controls ++(0.4189, 0) and ++(-0.2356, -0.2577) .. ++(0.9812, 0.3859) .. controls ++(0.2343, 0.2577) and ++(0, -0.4575) .. ++(0.3528, 1.0721) .. controls ++(0, 0.4437) and ++(0.237, -0.2618) .. ++(-0.3555, 1.0569) ++(-1.5172, -0.3431) .. controls ++(0.1116, 0.1654) and ++(-0.2508, 0) .. ++(0.5443, 0.248) .. controls ++(0.4754, 0) and ++(0, 0.6408) .. ++(0.7138, -0.9619) .. controls ++(0, -0.6477) and ++(0.4727, 0) .. ++(-0.7097, -0.9715) .. controls ++(-0.4782, 0) and ++(0, -0.6477) .. ++(-0.718, 0.9715) .. controls ++(0, 0.31) and ++(-0.113, -0.1654) .. ++(0.1695, 0.7138)
		++(3.9439, 0.6849) to ++(-0.6849, 0) to ++(0, 0.1819) .. controls ++(0, 0.1681) and ++(-0.062, -0.0841) .. ++(0.0937, 0.3776) .. controls ++(0.0606, 0.0827) and ++(-0.135, 0) .. ++(0.2949, 0.1254) .. controls ++(0.1337, 0) and ++(-0.1475, 0.0469) .. ++(0.4217, -0.0717) to ++(0.1557, 0.452) .. controls ++(-0.2026, 0.0689) and ++(0.2095, 0) .. ++(-0.6187, 0.1033) .. controls ++(-0.3197, 0) and ++(0.1543, 0.1599) .. ++(-0.7111, -0.2398) .. controls ++(-0.1571, -0.1585) and ++(0, 0.3321) .. ++(-0.2343, -0.7373) to ++(0, -0.1819) to ++(-0.4616, -0.1833) to ++(0, -0.2784) to ++(0.4616, 0) to ++(0, -2.3537) to ++(0.5981, 0) to ++(0, 2.3537) to ++(0.6849, 0) to ++(0, 0.452)
		++(4.7005, -2.8057) ++(-1.3891, 3.7235) to ++(-0.6587, 0) to ++(-1.3877, -3.7235) to ++(0.6394, 0) to ++(0.3624, 1.0294) to ++(1.418, 0) to ++(0.3707, -1.0294) to ++(0.6394, 0) to ++(-1.3835, 3.7235)
		++(-0.532, -1.204) .. controls ++(0.0882, 0.2467) and ++(-0.0441, -0.2081) .. ++(0.1998, 0.6821) .. controls ++(0.0179, -0.0675) and ++(-0.0455, 0.1447) .. ++(0.0937, -0.3197) .. controls ++(0.0441, -0.1461) and ++(-0.0248, 0.0675) .. ++(0.1047, -0.3197) to ++(0.3473, -1.0101) to ++(-1.079, 0) to ++(0.333, 0.9674)
		++(4.669, -2.184) .. controls ++(0.1984, 0.2577) and ++(0, -0.4575) .. ++(0.2977, 1.0721) .. controls ++(0, 0.4589) and ++(0.1957, -0.2536) .. ++(-0.2935, 1.0694) .. controls ++(-0.1943, 0.2522) and ++(0.35, 0) .. ++(-0.8186, 0.3803) .. controls ++(-0.3707, 0) and ++(0.1847, 0.2853) .. ++(-0.8351, -0.4272) to ++(-0.0303, 0) .. controls ++(-0.0441, 0.1984) and ++(0.0124, -0.0524) .. ++(-0.0841, 0.3762) to ++(-0.4823, 0) to ++(0, -4.0542) to ++(0.5967, 0) to ++(0, 1.1493) .. controls ++(0, 0.051) and ++(0.0234, -0.237) .. ++(-0.0358, 0.4313) to ++(0.0358, 0) .. controls ++(0.1957, -0.2549) and ++(-0.3555, 0) .. ++(0.8268, -0.3831) .. controls ++(0.35, 0) and ++(-0.1998, -0.2577) .. ++(0.8227, 0.3859) ++(-0.4796, 1.7928) .. controls ++(0.1102, -0.1626) and ++(0, 0.3128) .. ++(0.1654, -0.7138) .. controls ++(0, -0.3142) and ++(0.1116, 0.1681) .. ++(-0.1667, -0.7235) .. controls ++(-0.1116, -0.1695) and ++(0.2067, 0) .. ++(-0.4768, -0.2549) .. controls ++(-0.2453, 0) and ++(0.1075, -0.1529) .. ++(-0.5305, 0.2301) .. controls ++(-0.1089, 0.153) and ++(0, -0.3404) .. ++(-0.1612, 0.7414) to ++(0, 0.0896) .. controls ++(0, 0.3046) and ++(-0.1089, -0.1392) .. ++(0.1626, 0.6642) .. controls ++(0.1089, 0.1392) and ++(-0.2356, 0) .. ++(0.5181, 0.2081) .. controls ++(0.215, 0) and ++(-0.1102, 0.1599) .. ++(0.4892, -0.2412)
		++(3.7166, -1.7928) .. controls ++(0.1984, 0.2577) and ++(0, -0.4575) .. ++(0.3018, 1.0721) .. controls ++(0, 0.4589) and ++(0.1971, -0.2536) .. ++(-0.2963, 1.0694) .. controls ++(-0.1929, 0.2522) and ++(0.3528, 0) .. ++(-0.8186, 0.3803) .. controls ++(-0.3707, 0) and ++(0.1874, 0.2853) .. ++(-0.8365, -0.4272) to ++(-0.0289, 0) .. controls ++(-0.0427, 0.1984) and ++(0.0152, -0.0524) .. ++(-0.0854, 0.3762) to ++(-0.4782, 0) to ++(0, -4.0542) to ++(0.5926, 0) to ++(0, 1.1493) .. controls ++(0, 0.051) and ++(0.0235, -0.237) .. ++(-0.0331, 0.4313) to ++(0.0331, 0) .. controls ++(0.1971, -0.2549) and ++(-0.3528, 0) .. ++(0.8268, -0.3831) .. controls ++(0.3528, 0) and ++(-0.1971, -0.2577) .. ++(0.8227, 0.3859) ++(-0.4782, 1.7928) .. controls ++(0.1116, -0.1626) and ++(0, 0.3128) .. ++(0.1681, -0.7138) .. controls ++(0, -0.3142) and ++(0.1116, 0.1681) .. ++(-0.1681, -0.7235) .. controls ++(-0.113, -0.1695) and ++(0.2067, 0) .. ++(-0.4754, -0.2549) .. controls ++(-0.2453, 0) and ++(0.1075, -0.1529) .. ++(-0.5319, 0.2301) .. controls ++(-0.1075, 0.153) and ++(0, -0.3404) .. ++(-0.164, 0.7414) to ++(0, 0.0896) .. controls ++(0, 0.3046) and ++(-0.1075, -0.1392) .. ++(0.164, 0.6642) .. controls ++(0.1075, 0.1392) and ++(-0.2398, 0) .. ++(0.5223, 0.2081) .. controls ++(0.2122, 0) and ++(-0.1089, 0.1599) .. ++(0.4851, -0.2412)
		++(2.0726, 1.819) to ++(-0.5967, 0) to ++(0, -3.9467) to ++(0.5967, 0) to ++(0, 3.9467)
		++(1.4263, -1.141) to ++(-0.5981, 0) to ++(0, -2.8057) to ++(0.5981, 0) to ++(0, 2.8057) ++(-0.5457, 0.503) .. controls ++(0.0606, -0.0579) and ++(-0.1089, 0) .. ++(0.2494, -0.0882) .. controls ++(0.1089, 0) and ++(-0.0565, -0.0579) .. ++(0.2439, 0.0882) .. controls ++(0.062, 0.0579) and ++(0, -0.102) .. ++(0.0896, 0.2398) .. controls ++(0, 0.1061) and ++(0.062, -0.0579) .. ++(-0.0896, 0.2467) .. controls ++(-0.0565, 0.0565) and ++(0.1089, 0) .. ++(-0.2439, 0.0854) .. controls ++(-0.1089, 0) and ++(0.0606, 0.0565) .. ++(-0.2494, -0.0854) .. controls ++(-0.0565, -0.0579) and ++(0, 0.1061) .. ++(-0.0841, -0.2467) .. controls ++(0, -0.102) and ++(-0.0565, 0.0579) .. ++(0.0841, -0.2398) 
		++(3.1185, -3.3169) .. controls ++(0.1502, 0.0289) and ++(-0.1461, -0.0688) .. ++(0.4424, 0.1474) to ++(0, 0.4851) .. controls ++(-0.164, -0.073) and ++(0.1419, 0.0317) .. ++(-0.4616, -0.1571) .. controls ++(-0.1406, -0.0303) and ++(0.164, 0) .. ++(-0.4603, -0.0455) .. controls ++(-0.2536, 0) and ++(0.1419, -0.1461) .. ++(-0.5884, 0.2191) .. controls ++(-0.1364, 0.1461) and ++(0.0096, -0.2729) .. ++(-0.2205, 0.627) to ++(1.8714, 0) to ++(0, 0.3225) .. controls ++(0, 0.3941) and ++(0.2164, -0.2246) .. ++(-0.3238, 0.9288) .. controls ++(-0.2108, 0.2246) and ++(0.3679, 0) .. ++(-0.8751, 0.3376) .. controls ++(-0.3996, 0) and ++(0.226, 0.2618) .. ++(-0.9412, -0.3941) .. controls ++(-0.2301, -0.2618) and ++(0, 0.4589) .. ++(-0.3431, -1.0804) .. controls ++(0, -0.4465) and ++(-0.2439, 0.2549) .. ++(0.3666, -1.0514) .. controls ++(0.2453, -0.2536) and ++(-0.4368, 0) .. ++(1.0253, -0.3817) .. controls ++(0.1888, 0) and ++(-0.1461, -0.0275) .. ++(0.5085, 0.0427) ++(-0.1736, 2.2338) .. controls ++(0.1075, -0.1199) and ++(-0.0041, 0.2315) .. ++(0.1681, -0.5264) to ++(-1.2733, 0) .. controls ++(0.0234, 0.2301) and ++(-0.113, -0.1185) .. ++(0.2067, 0.525) .. controls ++(0.113, 0.1199) and ++(-0.1929, 0) .. ++(0.4561, 0.1805) .. controls ++(0.1888, 0) and ++(-0.1089, 0.1185) .. ++(0.4424, -0.1791)
		++(3.2494, -1.8576) to ++(0.0289, 0) to ++(0.1034, -0.3679) to ++(0.4658, 0) to ++(0, 3.9467) to ++(-0.598, 0) to ++(0, -1.0225) .. controls ++(0, -0.1171) and ++(-0.0276, 0.2012) .. ++(0.0427, -0.4768) to ++(-0.0276, 0) .. controls ++(-0.1929, 0.2729) and ++(0.3666, 0) .. ++(-0.842, 0.4093) .. controls ++(-0.3528, 0) and ++(0.1971, 0.2549) .. ++(-0.8282, -0.3845) .. controls ++(-0.1971, -0.2563) and ++(0, 0.4603) .. ++(-0.2963, -1.0749) .. controls ++(0, -0.4589) and ++(-0.1929, 0.2536) .. ++(0.2921, -1.068) .. controls ++(0.1971, -0.2522) and ++(-0.3528, 0) .. ++(0.8227, -0.3803) .. controls ++(0.3666, 0) and ++(-0.1915, -0.2784) .. ++(0.8365, 0.4189) ++(-1.1755, 0.3087) .. controls ++(-0.1089, 0.1626) and ++(0, -0.3114) .. ++(-0.164, 0.7111) .. controls ++(0, 0.3142) and ++(-0.1185, -0.1695) .. ++(0.1736, 0.7262) .. controls ++(0.113, 0.1695) and ++(-0.2067, 0) .. ++(0.4796, 0.2549) .. controls ++(0.2494, 0) and ++(-0.113, 0.1488) .. ++(0.5402, -0.2232) .. controls ++(0.1185, -0.1488) and ++(0, 0.3542) .. ++(0.175, -0.7538) to ++(0, -0.0827) .. controls ++(-0.0041, -0.3087) and ++(0.1144, 0.1378) .. ++(-0.175, -0.6711) .. controls ++(-0.1075, -0.1378) and ++(0.2439, 0) .. ++(-0.5305, -0.2067) .. controls ++(-0.2205, 0) and ++(0.113, -0.164) .. ++(-0.4988, 0.2453)
		++(5.9545, 0.7662) .. controls ++(-0.0606, 0.124) and ++(0.1268, -0.0992) .. ++(-0.277, 0.3335) .. controls ++(-0.1268, 0.0965) and ++(0.2729, -0.1144) .. ++(-0.6022, 0.3169) .. controls ++(-0.2398, 0.0992) and ++(0.0896, -0.0606) .. ++(-0.4988, 0.2398) .. controls ++(-0.0937, 0.0606) and ++(0.0413, -0.0689) .. ++(-0.2012, 0.1943) .. controls ++(-0.0441, 0.0689) and ++(0, -0.0965) .. ++(-0.062, 0.2481) .. controls ++(0, 0.1406) and ++(-0.0992, -0.0841) .. ++(0.1516, 0.3376) .. controls ++(0.102, 0.0854) and ++(-0.1915, 0) .. ++(0.4451, 0.1282) .. controls ++(0.2604, 0) and ++(-0.328, 0.1392) .. ++(0.8847, -0.2081) to ++(0.1929, 0.4961) .. controls ++(-0.3528, 0.1543) and ++(0.3528, 0) .. ++(-1.0583, 0.2315) .. controls ++(-0.3721, 0) and ++(0.2219, 0.1778) .. ++(-0.8888, -0.266) .. controls ++(-0.2164, -0.1778) and ++(0, 0.3087) .. ++(-0.3294, -0.729) .. controls ++(0, -0.248) and ++(-0.1364, 0.1764) .. ++(0.2067, -0.6353) .. controls ++(0.1419, -0.175) and ++(-0.339, 0.1364) .. ++(0.7207, -0.4685) .. controls ++(0.3252, -0.1323) and ++(-0.1089, 0.0965) .. ++(0.6491, -0.3431) .. controls ++(0.102, -0.0951) and ++(0, 0.1392) .. ++(0.1543, -0.3528) .. controls ++(0, -0.153) and ++(0.113, 0.091) .. ++(-0.1695, -0.3666) .. controls ++(-0.1171, -0.0923) and ++(0.2412, 0) .. ++(-0.5319, -0.1378) .. controls ++(-0.164, 0) and ++(0.1888, -0.0455) .. ++(-0.5305, 0.0689) .. controls ++(-0.1929, 0.0455) and ++(0.1681, -0.0799) .. ++(-0.5402, 0.1874) to ++(0, -0.5733) .. controls ++(0.2673, -0.1309) and ++(-0.4189, 0) .. ++(1.0294, -0.1957) .. controls ++(0.4189, 0) and ++(-0.2412, -0.1874) .. ++(0.9881, 0.2811) .. controls ++(0.2356, 0.1888) and ++(0, -0.3294) .. ++(0.3569, 0.7772) .. controls ++(0, 0.1667) and ++(0.0565, -0.1226) .. ++(-0.0896, 0.4355)
		++(2.3564, -1.4538) .. controls ++(0.1185, 0.0289) and ++(-0.1075, -0.062) .. ++(0.339, 0.135) to ++(0, 0.5195) .. controls ++(-0.2356, -0.1309) and ++(0.2632, 0) .. ++(-0.7524, -0.1971) .. controls ++(-0.2356, 0) and ++(0.1226, -0.1584) .. ++(-0.5319, 0.237) .. controls ++(-0.1213, 0.1585) and ++(0, -0.3142) .. ++(-0.1833, 0.7083) .. controls ++(0, 0.6449) and ++(-0.4837, 0) .. ++(0.729, 0.9674) .. controls ++(0.1654, 0) and ++(-0.2536, 0.0992) .. ++(0.6256, -0.1474) to ++(0.1791, 0.4796) .. controls ++(-0.2356, 0.1102) and ++(0.2963, 0) .. ++(-0.8006, 0.1654) .. controls ++(-0.4313, 0) and ++(0.2301, 0.2522) .. ++(-0.9963, -0.3803) .. controls ++(-0.2356, -0.2536) and ++(0, 0.4713) .. ++(-0.3473, -1.0887) .. controls ++(0, -0.463) and ++(-0.2205, 0.248) .. ++(0.328, -1.0666) .. controls ++(0.2219, -0.248) and ++(-0.4244, 0) .. ++(0.9701, -0.3721) .. controls ++(0.1736, 0) and ++(-0.1213, -0.0262) .. ++(0.441, 0.04)
		++(1.5668, 2.8167) to ++(-0.5981, 0) to ++(0, -2.8057) to ++(0.5981, 0) to ++(0, 2.8057) ++(-0.5457, 0.503) .. controls ++(0.062, -0.0579) and ++(-0.1089, 0) .. ++(0.2494, -0.0882) .. controls ++(0.1089, 0) and ++(-0.0565, -0.0579) .. ++(0.2439, 0.0882) .. controls ++(0.062, 0.0579) and ++(0, -0.102) .. ++(0.0896, 0.2398) .. controls ++(0, 0.1061) and ++(0.062, -0.0579) .. ++(-0.0896, 0.2467) .. controls ++(-0.0565, 0.0565) and ++(0.1089, 0) .. ++(-0.2439, 0.0854) .. controls ++(-0.1089, 0) and ++(0.062, 0.0565) .. ++(-0.2494, -0.0854) .. controls ++(-0.0565, -0.0579) and ++(0, 0.1061) .. ++(-0.0841, -0.2467) .. controls ++(0, -0.102) and ++(-0.0565, 0.0579) .. ++(0.0841, -0.2398)
		++(3.1185, -3.3169) .. controls ++(0.1502, 0.0289) and ++(-0.1461, -0.0688) .. ++(0.4424, 0.1474) to ++(0, 0.4851) .. controls ++(-0.164, -0.073) and ++(0.1406, 0.0317) .. ++(-0.4603, -0.1571) .. controls ++(-0.1419, -0.0303) and ++(0.1654, 0) .. ++(-0.4616, -0.0455) .. controls ++(-0.2536, 0) and ++(0.1378, -0.1461) .. ++(-0.5884, 0.2191) .. controls ++(-0.1406, 0.1461) and ++(0.0096, -0.2729) .. ++(-0.2205, 0.627) to ++(1.8672, 0) to ++(0, 0.3225) .. controls ++(0, 0.3941) and ++(0.2164, -0.2246) .. ++(-0.3197, 0.9288) .. controls ++(-0.2164, 0.2246) and ++(0.3707, 0) .. ++(-0.8792, 0.3376) .. controls ++(-0.3955, 0) and ++(0.2301, 0.2618) .. ++(-0.9412, -0.3941) .. controls ++(-0.226, -0.2618) and ++(0, 0.4589) .. ++(-0.3376, -1.0804) .. controls ++(0, -0.4465) and ++(-0.2439, 0.2549) .. ++(0.3652, -1.0514) .. controls ++(0.2453, -0.2536) and ++(-0.4368, 0) .. ++(1.0253, -0.3817) .. controls ++(0.1888, 0) and ++(-0.1502, -0.0275) .. ++(0.5085, 0.0427) ++(-0.1736, 2.2338) .. controls ++(0.1075, -0.1199) and ++(-0.0041, 0.2315) .. ++(0.1681, -0.5264) to ++(-1.2733, 0) .. controls ++(0.0234, 0.2301) and ++(-0.1185, -0.1185) .. ++(0.2067, 0.525) .. controls ++(0.113, 0.1199) and ++(-0.1888, 0) .. ++(0.452, 0.1805) .. controls ++(0.1929, 0) and ++(-0.1075, 0.1185) .. ++(0.4465, -0.1791)
		++(3.9081, -0.3969) .. controls ++(0, 0.6849) and ++(0.6725, 0) .. ++(-1.006, 1.028) .. controls ++(-0.1929, 0) and ++(0.1557, 0.073) .. ++(-0.5181, -0.1102) .. controls ++(-0.1543, -0.073) and ++(0.0841, 0.1337) .. ++(-0.361, -0.3087) to ++(-0.0289, 0) to ++(-0.0841, 0.3679) to ++(-0.4658, 0) to ++(0, -2.8057) to ++(0.5926, 0) to ++(0, 1.3973) .. controls ++(0, 0.35) and ++(-0.1171, -0.1488) .. ++(0.1791, 0.7483) .. controls ++(0.113, 0.1488) and ++(-0.2494, 0) .. ++(0.5498, 0.2232) .. controls ++(0.1874, 0) and ++(-0.0841, 0.1062) .. ++(0.4134, -0.1599) .. controls ++(0.0909, -0.1061) and ++(0, 0.2164) .. ++(0.1323, -0.4837) to ++(0, -1.7253) to ++(0.5967, 0) to ++(-0, 1.8287)
		++(2.3992, -1.8397) .. controls ++(0.1226, 0.0289) and ++(-0.1089, -0.062) .. ++(0.3445, 0.135) to ++(0, 0.5195) .. controls ++(-0.2412, -0.1309) and ++(0.2632, 0) .. ++(-0.7538, -0.1971) .. controls ++(-0.2356, 0) and ++(0.1185, -0.1584) .. ++(-0.5319, 0.237) .. controls ++(-0.1213, 0.1585) and ++(0, -0.3142) .. ++(-0.1819, 0.7083) .. controls ++(0, 0.6449) and ++(-0.4837, 0) .. ++(0.7276, 0.9674) .. controls ++(0.1654, 0) and ++(-0.2494, 0.0992) .. ++(0.6215, -0.1474) to ++(0.1833, 0.4796) .. controls ++(-0.2398, 0.1102) and ++(0.2963, 0) .. ++(-0.7993, 0.1654) .. controls ++(-0.4382, 0) and ++(0.2301, 0.2522) .. ++(-1.0018, -0.3803) .. controls ++(-0.2301, -0.2536) and ++(0, 0.4713) .. ++(-0.3445, -1.0887) .. controls ++(0, -0.463) and ++(-0.2191, 0.248) .. ++(0.3294, -1.0666) .. controls ++(0.2219, -0.248) and ++(-0.4272, 0) .. ++(0.9688, -0.3721) .. controls ++(0.1695, 0) and ++(-0.1226, -0.0262) .. ++(0.4382, 0.04)
		++(2.6996, 0.003) .. controls ++(0.1502, 0.0289) and ++(-0.1461, -0.0688) .. ++(0.4424, 0.1474) to ++(0, 0.4851) .. controls ++(-0.164, -0.073) and ++(0.1419, 0.0317) .. ++(-0.4616, -0.1571) .. controls ++(-0.1447, -0.0303) and ++(0.1681, 0) .. ++(-0.4644, -0.0455) .. controls ++(-0.2494, 0) and ++(0.135, -0.1461) .. ++(-0.5829, 0.2191) .. controls ++(-0.1406, 0.1461) and ++(0.0096, -0.2729) .. ++(-0.2219, 0.627) to ++(1.8672, 0) to ++(0, 0.3225) .. controls ++(0, 0.3941) and ++(0.215, -0.2246) .. ++(-0.3183, 0.9288) .. controls ++(-0.2177, 0.2246) and ++(0.3721, 0) .. ++(-0.8806, 0.3376) .. controls ++(-0.401, 0) and ++(0.2288, 0.2618) .. ++(-0.9398, -0.3941) .. controls ++(-0.2274, -0.2618) and ++(0, 0.4589) .. ++(-0.3445, -1.0804) .. controls ++(0, -0.4465) and ++(-0.2453, 0.2549) .. ++(0.3721, -1.0514) .. controls ++(0.2439, -0.2536) and ++(-0.4368, 0) .. ++(1.0253, -0.3817) .. controls ++(0.1874, 0) and ++(-0.1488, -0.0275) .. ++(0.5071, 0.0427) ++(-0.1736, 2.2338) .. controls ++(0.1089, -0.1199) and ++(-0.0041, 0.2315) .. ++(0.1695, -0.5264) to ++(-1.2747, 0) .. controls ++(0.0234, 0.2301) and ++(-0.1171, -0.1185) .. ++(0.2067, 0.525) .. controls ++(0.113, 0.1199) and ++(-0.1888, 0) .. ++(0.452, 0.1805) .. controls ++(0.1929, 0) and ++(-0.1075, 0.1185) .. ++(0.4465, -0.1791)
		++(3.2646, -1.0776) .. controls ++(-0.0468, 0.0978) and ++(0.1047, -0.073) .. ++(-0.2315, 0.2563) .. controls ++(-0.1075, 0.0758) and ++(0.2356, -0.0896) .. ++(-0.5071, 0.2467) .. controls ++(-0.2729, 0.1061) and ++(0.0841, -0.0606) .. ++(-0.5361, 0.2508) .. controls ++(-0.0799, 0.062) and ++(0, -0.0882) .. ++(-0.1226, 0.2246) .. controls ++(0, 0.1791) and ++(-0.3156, 0) .. ++(0.4754, 0.2673) .. controls ++(0.2026, 0) and ++(-0.3059, 0.1254) .. ++(0.7621, -0.1874) to ++(0.1929, 0.4492) .. controls ++(-0.2963, 0.1337) and ++(0.3293, 0) .. ++(-0.9357, 0.2012) .. controls ++(-0.3349, 0) and ++(0.1929, 0.1323) .. ++(-0.791, -0.1998) .. controls ++(-0.1915, -0.1337) and ++(0, 0.2398) .. ++(-0.2908, -0.5595) .. controls ++(0, -0.1998) and ++(-0.1171, 0.1254) .. ++(0.1736, -0.4864) .. controls ++(0.1116, -0.1254) and ++(-0.3238, 0.124) .. ++(0.6532, -0.3748) .. controls ++(0.164, -0.0661) and ++(-0.0896, 0.051) .. ++(0.3872, -0.1736) .. controls ++(0.0923, -0.0496) and ++(-0.0427, 0.0469) .. ++(0.2012, -0.1461) .. controls ++(0.0413, -0.0482) and ++(0, 0.0703) .. ++(0.062, -0.1778) .. controls ++(0, -0.2219) and ++(0.3666, 0) .. ++(-0.5512, -0.3335) .. controls ++(-0.2825, 0) and ++(0.3293, -0.1529) .. ++(-0.9219, 0.2301) to ++(0, -0.5154) .. controls ++(0.226, -0.113) and ++(-0.3762, 0) .. ++(0.9026, -0.1709) .. controls ++(0.3721, 0) and ++(-0.2026, -0.1461) .. ++(0.8571, 0.2191) .. controls ++(0.1971, 0.1461) and ++(0, -0.2742) .. ++(0.3004, 0.6311) .. controls ++(0, 0.135) and ++(0.0524, -0.0978) .. ++(-0.0799, 0.3486)
		
		++(-68.618, 6.0037) ++(1.5448, 5.5025) to ++(0.0469, 0) .. controls ++(-0.0414, -0.8296) and ++(0.0041, 0.2122) .. ++(-0.0703, -1.5641) .. controls ++(-0.006, -0.2136) and ++(0, 0.1736) .. ++(-0.008, -0.5815) to ++(0, -3.3569) to ++(1.9003, 0) to ++(0, 7.655) to ++(-2.7588, 0) to ++(-1.5654, -5.435) to ++(-0.0427, 0) to ++(-1.5971, 5.435) to ++(-2.7533, 0) to ++(0, -7.655) to ++(1.8328, 0) to ++(0, 3.3252) .. controls ++(0, 0.5195) and ++(0.073, -0.9398) .. ++(-0.1102, 2.1883) to ++(0.0468, 0) to ++(1.5654, -5.5135) to ++(1.969, 0) to ++(1.592, 5.5025)
		++(5.779, 2.152) to ++(-2.0795, 0) to ++(0, -7.655) to ++(2.0795, 0) to ++(0, 7.655)
		++(5.2021, -1.6909) to ++(1.8645, 0) to ++(0, 1.6909) to ++(-5.8015, 0) to ++(0, -1.6909) to ++(1.87, 0) to ++(0, -5.9641) to ++(2.0671, 0) to ++(0, 5.9641)
		++(6.7951, 0) to ++(1.8631, 0) to ++(0, 1.6909) to ++(-5.8015, 0) to ++(0, -1.6909) to ++(1.87, 0) to ++(0, -5.9641) to ++(2.0684, 0) to ++(0, 5.9641)
		++(13.6164, 1.6909) to ++(-1.9954, 0) to ++(-0.8475, -3.8489) .. controls ++(-0.2012, -0.9564) and ++(0.0441, 0.3872) .. ++(-0.3707, -2.0147) .. controls ++(-0.0386, 0.299) and ++(0.1144, -0.6063) .. ++(-0.2301, 1.3601) .. controls ++(-0.1158, 0.6077) and ++(0.1116, -0.4644) .. ++(-0.3418, 1.6082) to ++(-0.6546, 2.8953) to ++(-1.9155, 0) to ++(-0.6752, -2.8953) .. controls ++(-0.102, -0.401) and ++(0.1171, 0.6105) .. ++(-0.328, -1.5186) .. controls ++(-0.1171, -0.6105) and ++(0.0469, 0.3555) .. ++(-0.2439, -1.4497) .. controls ++(-0.0689, 0.5016) and ++(0.1888, -0.8489) .. ++(-0.3872, 2.0257) to ++(-0.831, 3.8378) to ++(-1.9968, 0) to ++(1.8962, -7.655) to ++(2.4446, 0) .. controls ++(0.4479, 2.0078) and ++(-0.0606, -0.2839) .. ++(0.7621, 3.4355) .. controls ++(0.0606, 0.2825) and ++(-0.0634, -0.3362) .. ++(0.1874, 0.9288) .. controls ++(0.0606, 0.3376) and ++(-0.0276, -0.2274) .. ++(0.135, 0.8461) .. controls ++(0.0358, -0.2798) and ++(-0.0744, 0.4162) .. ++(0.164, -1.0432) .. controls ++(0.0758, -0.4148) and ++(-0.0358, 0.1392) .. ++(0.1667, -0.831) to ++(0.7317, -3.3362) to ++(2.446, 0) to ++(1.8838, 7.655)
		++(5.7561, -5.9683) to ++(-2.475, 0) to ++(0, 1.4442) to ++(2.2903, 0) to ++(0, 1.6605) to ++(-2.2903, 0) to ++(0, 1.2044) to ++(2.475, 0) to ++(0, 1.6592) to ++(-4.5448, 0) to ++(0, -7.655) to ++(4.5448, 0) to ++(0, 1.6867)
		++(3.7717, 5.9683) to ++(-2.0795, 0) to ++(0, -7.655) to ++(2.0795, 0) to ++(0, 7.655)
		++(7.3711, -0.9426) .. controls ++(-0.6683, 0.6284) and ++(1.2292, 0) .. ++(-2.847, 0.9426) to ++(-2.6472, 0) to ++(0, -7.655) to ++(2.4736, 0) .. controls ++(1.2747, 0) and ++(-0.7056, -0.6918) .. ++(2.9683, 1.0363) .. controls ++(0.7014, 0.6918) and ++(0, -1.2774) .. ++(1.0542, 2.9531) .. controls ++(0, 1.1879) and ++(0.667, -0.6284) .. ++(-1.0018, 2.723) ++(-1.5847, -4.469) .. controls ++(-0.2921, -0.3638) and ++(0.6298, 0) .. ++(-1.3836, -0.5471) to ++(-0.4616, 0) to ++(0, 4.2885) to ++(0.6022, 0) .. controls ++(0.5691, 0) and ++(-0.277, 0.339) .. ++(1.265, -0.5085) .. controls ++(0.2784, -0.339) and ++(0, 0.7014) .. ++(0.4203, -1.5599) .. controls ++(0, -0.751) and ++(0.2963, 0.3652) .. ++(-0.4423, -1.6729)
		++(10.5585, -2.2434) ++(-2.5259, 7.6867) to ++(-2.7616, 0) to ++(-2.497, -7.6867) to ++(2.2724, 0) to ++(0.3914, 1.4345) to ++(2.4818, 0) to ++(0.3817, -1.4345) to ++(2.257, 0) to ++(-2.526, 7.6867) ++(-2.168, -4.556) .. controls ++(0.3197, 1.2003) and ++(-0.0951, -0.4093) .. ++(0.616, 2.4143) .. controls ++(0.0896, 0.4079) and ++(-0.0276, -0.1778) .. ++(0.1833, 0.8792) .. controls ++(0.0386, -0.1916) and ++(-0.1089, 0.4423) .. ++(0.2164, -0.9522) .. controls ++(0.113, -0.4437) and ++(-0.0758, 0.2798) .. ++(0.2825, -1.0845) to ++(0.3294, -1.2568) to ++(-1.6275, -0)
		
		++(-52.907, 14.416) to ++(-2.0781, 0) to ++(0, -2.8374) to ++(-2.4047, 0) to ++(0, 2.8374) to ++(-2.0781, 0) to ++(0, -7.655) to ++(2.0781, 0) to ++(0, 3.1199) to ++(2.4047, 0) to ++(0, -3.1199) to ++(2.0781, 0) to ++(0, 7.655)
		++(8.0698, -0.8806) .. controls ++(-0.6284, 0.667) and ++(1.2168, 0) .. ++(-2.7699, 1.0005) .. controls ++(-1.2154, 0) and ++(0.6367, 0.6725) .. ++(-2.7781, -1.0073) .. controls ++(-0.6367, -0.6725) and ++(0, 1.2733) .. ++(-0.9564, -2.9187) .. controls ++(0, -1.2885) and ++(-0.6408, 0.6739) .. ++(0.9619, -2.9435) .. controls ++(0.6394, -0.6739) and ++(-1.2003, 0) .. ++(2.7616, -1.0101) .. controls ++(1.2182, 0) and ++(-0.6325, -0.6697) .. ++(2.7754, 1.0046) .. controls ++(0.6312, 0.6711) and ++(0, -1.2871) .. ++(0.9467, 2.938) .. controls ++(0, 1.2912) and ++(0.627, -0.6656) .. ++(-0.9412, 2.9366) ++(-2.7699, -0.6959) .. controls ++(0.5085, 0) and ++(-0.2563, 0.3638) .. ++(1.1479, -0.5471) .. controls ++(0.2577, -0.3652) and ++(0, 0.7634) .. ++(0.3859, -1.6936) .. controls ++(0, -0.7621) and ++(0.2536, 0.3597) .. ++(-0.3803, -1.6812) .. controls ++(-0.2522, -0.3597) and ++(0.5237, 0) .. ++(-1.1645, -0.5388) .. controls ++(-1.0308, 0) and ++(0, -1.48) .. ++(-1.5448, 2.22) .. controls ++(0, 1.4938) and ++(-1.0377, 0) .. ++(1.5558, 2.2407)
		++(9.587, -0.1461) .. controls ++(0.2839, -0.0923) and ++(-0.2839, 0.1337) .. ++(0.8489, -0.3362) to ++(0.6325, 1.6288) .. controls ++(-0.7538, 0.3597) and ++(0.8268, 0) .. ++(-2.3702, 0.5402) .. controls ++(-0.7579, 0) and ++(0.5609, 0.3225) .. ++(-1.9775, -0.4851) .. controls ++(-0.5609, -0.3238) and ++(0.299, 0.6008) .. ++(-1.2885, -1.3849) .. controls ++(-0.2977, -0.6008) and ++(0, 0.7924) .. ++(-0.4479, -2.0891) .. controls ++(0, -1.2678) and ++(-0.616, 0.6711) .. ++(0.9247, -2.9063) .. controls ++(0.616, -0.6697) and ++(-1.1548, 0) .. ++(2.6569, -1.0046) .. controls ++(0.8075, 0) and ++(-0.6394, -0.2839) .. ++(2.1677, 0.4244) to ++(0, 1.7474) .. controls ++(-0.3211, -0.1323) and ++(0.317, 0.0937) .. ++(-0.9577, -0.339) .. controls ++(-0.3169, -0.0951) and ++(0.3376, 0) .. ++(-0.9839, -0.1419) .. controls ++(-1.1203, 0) and ++(0, -1.4731) .. ++(-1.6812, 2.2104) .. controls ++(0, 0.7083) and ++(-0.2756, -0.4038) .. ++(0.4134, 1.6674) .. controls ++(0.2756, 0.4024) and ++(-0.4933, 0) .. ++(1.152, 0.6036) .. controls ++(0.3252, 0) and ++(-0.2825, 0.091) .. ++(0.9109, -0.1351)
		++(9.3679, 1.7226) to ++(-2.0795, 0) to ++(0, -2.8374) to ++(-2.4047, 0) to ++(0, 2.8374) to ++(-2.0781, 0) to ++(0, -7.655) to ++(2.0781, 0) to ++(0, 3.1199) to ++(2.4047, 0) to ++(0, -3.1199) to ++(2.0795, 0) to ++(0, 7.655)
		++(6.5925, -4.0445) .. controls ++(-0.2577, 0.339) and ++(0.6601, -0.2963) .. ++(-1.3753, 0.955) .. controls ++(-0.6876, 0.3142) and ++(0.1557, -0.1185) .. ++(-1.265, 0.6491) .. controls ++(-0.1543, 0.1185) and ++(0, -0.1502) .. ++(-0.2329, 0.4038) .. controls ++(0, 0.1392) and ++(-0.1226, -0.0937) .. ++(0.1833, 0.35) .. controls ++(0.124, 0.0951) and ++(-0.2701, 0) .. ++(0.587, 0.1419) .. controls ++(0.5195, 0) and ++(-0.7152, 0.328) .. ++(1.8535, -0.492) to ++(0.6339, 1.5971) .. controls ++(-0.8241, 0.3666) and ++(0.7938, 0) .. ++(-2.4253, 0.5498) .. controls ++(-0.8957, 0) and ++(0.5126, 0.3941) .. ++(-2.1139, -0.5926) .. controls ++(-0.514, -0.3941) and ++(0, 0.7055) .. ++(-0.7703, -1.6495) .. controls ++(0, -0.3762) and ++(-0.1213, 0.2756) .. ++(0.1819, -0.9784) .. controls ++(0.1199, -0.2756) and ++(-0.2494, 0.2136) .. ++(0.554, -0.7331) .. controls ++(0.2494, -0.2136) and ++(-0.4988, 0.2274) .. ++(1.1231, -0.6601) .. controls ++(0.5512, -0.2467) and ++(-0.1268, 0.0799) .. ++(1.0184, -0.492) .. controls ++(0.1282, -0.0813) and ++(-0.0579, 0.0786) .. ++(0.2784, -0.2384) .. controls ++(0.0565, -0.0786) and ++(0, 0.1034) .. ++(0.0854, -0.2742) .. controls ++(0, -0.1681) and ++(0.1433, 0.1061) .. ++(-0.215, -0.412) .. controls ++(-0.1433, -0.1061) and ++(0.3073, 0) .. ++(-0.6752, -0.1599) .. controls ++(-0.3569, 0) and ++(0.4258, -0.113) .. ++(-1.1727, 0.1709) .. controls ++(-0.4258, 0.113) and ++(0.3941, -0.2026) .. ++(-1.2306, 0.474) to ++(0, -1.8424) .. controls ++(0.3734, -0.1791) and ++(-0.3445, 0.0703) .. ++(1.0776, -0.3748) .. controls ++(0.3473, -0.0717) and ++(-0.5099, 0) .. ++(1.2843, -0.1075) .. controls ++(0.6105, 0) and ++(-0.4534, -0.2039) .. ++(1.5958, 0.3059) .. controls ++(0.4548, 0.2039) and ++(-0.2412, -0.3679) .. ++(1.0432, 0.8585) .. controls ++(0.2412, 0.3679) and ++(0, -0.4754) .. ++(0.361, 1.265) .. controls ++(0, 0.5154) and ++(0.2563, -0.3404) .. ++(-0.3845, 1.2857)
		++(6.1144, 2.322) .. controls ++(0.2811, -0.0923) and ++(-0.2825, 0.1337) .. ++(0.8461, -0.3362) to ++(0.6339, 1.6288) .. controls ++(-0.751, 0.3597) and ++(0.8268, 0) .. ++(-2.3688, 0.5402) .. controls ++(-0.7579, 0) and ++(0.5595, 0.3225) .. ++(-1.9761, -0.4851) .. controls ++(-0.565, -0.3238) and ++(0.2977, 0.6008) .. ++(-1.2898, -1.3849) .. controls ++(-0.299, -0.6008) and ++(0, 0.7924) .. ++(-0.4492, -2.0891) .. controls ++(0, -1.2678) and ++(-0.6174, 0.6711) .. ++(0.926, -2.9063) .. controls ++(0.616, -0.6697) and ++(-1.1562, 0) .. ++(2.6555, -1.0046) .. controls ++(0.8048, 0) and ++(-0.6408, -0.2839) .. ++(2.1704, 0.4244) to ++(0, 1.7474) .. controls ++(-0.3252, -0.1323) and ++(0.3197, 0.0937) .. ++(-0.9605, -0.339) .. controls ++(-0.3142, -0.0951) and ++(0.3376, 0) .. ++(-0.9825, -0.1419) .. controls ++(-1.119, 0) and ++(0, -1.4731) .. ++(-1.684, 2.2104) .. controls ++(0, 0.7083) and ++(-0.2729, -0.4038) .. ++(0.4134, 1.6674) .. controls ++(0.2784, 0.4024) and ++(-0.4906, 0) .. ++(1.1534, 0.6036) .. controls ++(0.3238, 0) and ++(-0.2839, 0.091) .. ++(0.9123, -0.1351)
		++(9.3638, 1.7226) to ++(-2.0781, 0) to ++(0, -2.8374) to ++(-2.3992, 0) to ++(0, 2.8374) to ++(-2.0795, 0) to ++(0, -7.655) to ++(2.0795, 0) to ++(0, 3.1199) to ++(2.3992, 0) to ++(0, -3.1199) to ++(2.0781, 0) to ++(0, 7.655)
		++(6.3224, 0) to ++(0, -4.4828) .. controls ++(0, -0.5512) and ++(0.1874, 0.2425) .. ++(-0.2825, -1.1906) .. controls ++(-0.1929, -0.2425) and ++(0.4231, 0) .. ++(-0.9205, -0.3638) .. controls ++(-0.3955, 0) and ++(0.2026, -0.2439) .. ++(-0.8943, 0.3666) .. controls ++(-0.204, 0.2439) and ++(0, -0.5416) .. ++(-0.3059, 1.1782) to ++(0, 4.4924) to ++(-2.0795, 0) to ++(0, -4.655) .. controls ++(0, -1.0018) and ++(-0.5595, 0.5347) .. ++(0.842, -2.3041) .. controls ++(0.5609, -0.5347) and ++(-1.039, 0) .. ++(2.4033, -0.8006) .. controls ++(1.0735, 0) and ++(-0.5691, -0.5498) .. ++(2.4557, 0.8241) .. controls ++(0.5691, 0.5498) and ++(0, -1.0018) .. ++(0.8516, 2.3275) to ++(0, 4.6082) to ++(-2.0698, 0)
		++(8.9187, -7.655) to ++(0, 1.6702) to ++(-2.9504, 0) to ++(0, 5.9848) to ++(-2.0643, 0) to ++(0, -7.655) to ++(5.0147, 0)
		++(5.8746, 1.6853) to ++(-2.4791, 0) to ++(0, 1.4456) to ++(2.2958, 0) to ++(0, 1.6605) to ++(-2.2958, 0) to ++(0, 1.203) to ++(2.4791, 0) to ++(0, 1.6605) to ++(-4.5489, 0) to ++(0, -7.655) to ++(4.5489, 0) to ++(0, 1.6853)
		;
	\end{scope}
}
\NewDocumentCommand{\logo}{ssomm}% with savespace*, draw savespace**, [background color], color, width
{%
	\begin{tikzpicture}
		% Rescale lengths depending on logo size
		\edef\stars{\IfValueTF{#3}{**}{\IfBooleanTF{#1}{*}{}}}
		\expandafter\logoScaleToWidth\stars{#5}
		
		\IfValueTF{#3}% Draw background
		{\logoDesignBackgroundPath(-3\luw-2\luws, 2\luw+\luws+\luh+\luhs+\luhx){designtop}{#3}}{}
		
		% Draw Foreground
		\logoDesignMarkPath{designmark}{#4}
		\logoWordMarkPath(4\luw + 3\luws, \luh+\luhs+\luhx-\luw-\luws){wordmark}{#4}
		
		%Draw savespaces
		\IfBooleanTF{#1}
		{
			\draw[draw=\IfBooleanTF{#2}{#4}{none}] ([xshift=-\luw, yshift=-\luw] designmark.south west) |- ([xshift=\luw, yshift=\luw] designmark.north -| wordmark.east) |- cycle;
			
			\IfValueTF{#3}
			{\draw[draw=\IfBooleanTF{#2}{#4}{none}] ([xshift=-(3\luw + 2\luws), yshift=-(3\luw + 2\luws)] designmark.west |- wordmark.south) |- ([xshift=(3\luw + 2\luws), yshift=(2\luw+\luws)] designmark.north -| wordmark.east) |- cycle;}{}	
		}{}
	\end{tikzpicture}%
}
\NewDocumentCommand{\logoDesignBackgroundBottom}{mm}%
{%
	\begin{tikzpicture}
		% Rescale lengths depending on logo size
		\logoScaleToWidth**{#2}
		
		\logoDesignBackgroundPath*{designbottom}{#1}
	\end{tikzpicture}%
}