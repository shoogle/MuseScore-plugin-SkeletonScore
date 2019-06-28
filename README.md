# SkeletonScore

A plugin for [MuseScore]. Quickly add line breaks, page breaks, and section
breaks to a score to match the layout of a PDF or paper edition.

[MuseScore]: https://musescore.org/ "Open source music notation editor"

## Instructions

The plugin opens a dialog with a text field where you can write your layout in
code form, such as:

```
4 5 4
3 4
```

Each row of numbers represents a page of music in the score, and each number
represents the number of measures in one system.

The code basically means:

- Skip __4 measures__ and add a __line break__
- Skip __5 measures__ and add a __line break__
- Skip __4 measures__ and add a __page break__ (i.e. create a 2nd page)
- Skip __3 measures__ and add a __line break__
- The final system contains __4 measures__.

The type of layout break used is determined by the whitespace character(s)
immediately following each number. The possible values are:

- __Space__ (` `) - adds a line break
- __Newline__ (`\n`) - adds a page break
- __Double newline__ (`\n\n`) - adds a section break
