# wordcloud

This package (MetaPost, Lua, and LaTeX) allows you to draw wordclouds.

_This package is in beta version, do not hesitate to report bugs, as well as
requests for improvement. There is lots to do!_

## Github

To allow for easier feedback and bug reporting, this repository has a mirror
repository on github:
[https://github.com/chupinmaxime/mpchess](https://github.com/chupinmaxime/wordcloud) 

## Installation

MPchess is on the [ctan](ctan.org) and can be installed via the package manager of your
distribution [https://www.ctan.org/pkg/mpchess](https://www.ctan.org/pkg/wordcloud).

### With TeX live under Linux or MacOS

To install `wordcloud` with TeX live, you will have to create the directory `texmf`
directory in your home. 
```bash
user $> mkdir ~/texmf
```

Then, you will have to place the .mp files in the
`~/texmf/tex/metapost/wordcloud/`.

`wordcloud` consists of 3 files:
* `wordcloud.mp` (MetaPost);
* `wordcloud.tex` (LaTeX);
* `wordcloud.lua` (Lua).



### With MikTEX and Windows

These two systems are unknown to the author of MPchess, so we refer to their
documentation to add local packages:
[http://docs.miktex.org/manual/localadditions.html](http://docs.miktex.org/manual/localadditions.html)

## Dependencies


## Documentation

* [English documentation](doc/wordcloud.pdf)

## Contact

Maxime Chupin, `notezik(at)gmail.com`

## Licenses

This projet is under LATEX Project Public License 1.3c. 