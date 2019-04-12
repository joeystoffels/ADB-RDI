
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{template/han}

\LoadClass{article}
\RequirePackage[margin=3cm,a4paper]{geometry}

% Packages
\RequirePackage[utf8]{inputenc}
\RequirePackage{listings}               % For showing code
\RequirePackage{color}                  % For color
\RequirePackage{graphicx}               % For images
\RequirePackage[sfdefault]{cabin}       % For font
\RequirePackage[T1]{fontenc}            % For font
\RequirePackage{courier}                % For code font
\RequirePackage{wallpaper}              % For background
\RequirePackage[many]{tcolorbox}        % For whitebox behind title
\RequirePackage[dutch]{babel}           % Nederlands taalpakket

% Bibliograpy
\RequirePackage[style=apa]{biblatex}
\addbibresource{publication.bib}

%Colors
\definecolor{codegreen}{rgb}{0,0.6,0}
\definecolor{codegray}{rgb}{0.5,0.5,0.5}
\definecolor{codepurple}{rgb}{0.58,0,0.82}
\definecolor{backcolour}{rgb}{0.94, 0.97, 1.0}

%Background image for the first page
\ThisCenterWallPaper{1.6}{template/images/background.eps} % Add wallpaper

% Transparent backgourd color box
\newtcolorbox{backgroundTransparent}[1][]{
    width=\textwidth,
    arc=3mm,
    %    auto outer arc,
    boxsep=0cm,
    toprule=2pt,
    leftrule=2pt,
    bottomrule=2pt,
    rightrule=2pt,
    colframe=white,
    fontupper=\raggedleft\fontsize{16pt}{16pt}\itshape,
    breakable,
    nobeforeafter,
    enhanced jigsaw,
    opacityframe=0.5,
    opacityback=0.7
}


% Style for code
\lstdefinestyle{mystyle}{
    backgroundcolor=\color{backcolour},
    commentstyle=\color{codegreen},
    keywordstyle=\color{magenta},
    numberstyle=\tiny\color{codegray},
    stringstyle=\color{codepurple},
    basicstyle=\footnotesize\ttfamily,
    breakatwhitespace=false,
    breaklines=true,
    captionpos=b,
    keepspaces=true,
    %numbers=left,
    numbers=none,
    numbersep=5pt,
    showspaces=false,
    showstringspaces=false,
    showtabs=false,
    tabsize=2
}
\lstset{style=mystyle}

% MakeTitle
\renewcommand{\maketitle}{
    \begin{titlepage}

        \begin{minipage}[t]{1.0\textwidth}
            \includegraphics[scale=0.07]{template/images/han/han-hogeschool-van-arnhem-en-nijmegen-logo.eps}
        \end{minipage}
        \begin{minipage}[t]{1.0\textwidth}
            \vspace{-1.7cm}
            \hfill
            \includegraphics[scale=0.6]{template/images/han/logo_ica.eps}
        \end{minipage}

        \begin{minipage}{\textwidth}

            \vspace{1.5cm}

            \begin{minipage}[t]{1.0\textwidth}
                \begin{backgroundTransparent}[]
                    \begin{flushright}
                        \Huge{\@title}
                    \end{flushright}
                    \begin{flushright}
                        \Large{\today}
                    \end{flushright}
                \end{backgroundTransparent}
            \end{minipage}
        \end{minipage}

        \mbox{} % Allign to the bottom
        \vfill

        \small
        \begin{flushleft}
            \textbf{Docent(en):} \newline
            \docenten
        \end{flushleft}

        \begin{flushleft}
            \textbf{Student(en):} \newline
            \@author
        \end{flushleft}

        \begin{flushleft}
            Vak: \vak
        \end{flushleft}

    \end{titlepage}
}
