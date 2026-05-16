---
title: "Column with a G"
date: 2024-12-20
created: 2024-12-20T00:00:00Z
type: blog
status: settled
tags: [life]
publish: [ddrscott]
source: import
description: "How to view large CSV files."
image: /images/2024/golumn-demo.png
prompt: "Import from blog post: 2024/column-with-a-g.md"
---

# Column with a G

<img class="featured" src="/images/2024/golumn-demo.png" alt="screenshot of data grid" />

I have a pet named `Golumn`, pronounced like "column" with a "G". It's a pet project to be more precise, and out of all my pets Golumn is my favorite, just don't tell the others.

Have you ever received a CSV (Comma Separated Value) file that's a gigabyte or more from a data vendor that you're just checking out for the first time, try to open it and wait for Excel to read everything into memory and then crashes with an "Out of Memory" error? So then you have to split up the file into something smaller, and try again. But how can you make it smaller if you can't open it in Excel? So you roll up your sleeves and break out some ETL tools to view it. Then you realize you have a to write a script because ETL needs the data in a slightly different format? Well, after repeating this pattern for 19 years (2017 - 1998) or so, I had to fix this once and for all. No more work before the work. I needed a way to preview the data before doing any heavy lifting.

Even in 2024, this is still a problem!

- Excel Crashing with 1.5GB File - Any Suggestions? [Reddit](https://www.reddit.com/r/excel/comments/1f74uyo/excel_crashing_with_15gb_file_any_suggestions/)
- What to do if a data set is too large for the Excel grid [Microsoft](https://support.microsoft.com/en-us/office/what-to-do-if-a-data-set-is-too-large-for-the-excel-grid-976e6a34-9756-48f4-828c-ca80b3d0e15c)

<img class="featured" src="https://support.content.office.net/en-us/media/2dc0545d-1e3c-40df-8e0b-dd98e5afa45d.png" alt="Excel Warning, Data set too large" />

In 2017, I set out to create the **fastest** CSV viewer known to the Internet. I searched for alternatives to Excel to make sure the my problem wasn't already solved. I found some that were IDE specific, for IDE's that I don't use. I found some that were Electron based, but Electron's startup time was slow back then. And there were some open source options, but they didn't scratch the itch. Many of the tools still required me to know the structure of the file before opening it.

## My Deepest Needs

- **Speed!** I need to view the data before it finishes loading it.
- **Good Guessing**. I don't want to pick the column separator,line delimiter, or quoting before preview.
- **Fault tolerance**. Let me see the data even if the guessed format is bad so I can be more informed for the next attempt.

## Command Line Junky

Did you know CSVs can be read from command line? This is the way I lived before Golumn. If you're in a POSIX (Linux, Mac, Unix) environment, you can try:

```sh
head -100 /path/to/file.csv | column -ts, | less -S
```

**Command Breakdown**:

* `head -100 /path/to/file` get the first 100 lines of a file
* `column -ts,` print in table `-t` format separated by comma `-s,`
* `less -NS` paginate the result with line numbers `-N` and horizontal scrolling `-S`

The command line way, checks all 3 needs. It's fast, it let's me see results, and it's fault tolerant. It _may_ look like crap if the delimiter is wrong, but that's easy to remediate with different flags, and because I can see something, it allows for quick adjustments. For instance, `column -t-s\|` would split on pipe instead of comma.

This is nice and all, but every once in a while, a graphical interface is needed to get a better feel for the data. GUIs provide for smooth scrolling and higher resolution than the terminal. It's also nice to have numbers aligned properly and clickable things.

## Golumn is Born

Golumn is a Python project built with wxPython built on wxWidgets. It leverages Python's CSV sniffer and SQLite for data processing.

https://pypi.org/project/golumn/

<img class="featured" src="/images/2024/golumn-pypi.png" alt="screenshot of data grid" />

The command, `golumn /path/to/file.csv`, will open a GUI Window showing data in 0.1 seconds with a simple grid of data scrollable till my fingers get tired.

Overtime, I've added keyboard shortcuts to quick filter/unfilter data based on the current selection, sort columns, and search and filter any column for a piece of text, but at it's core, it's a sharp tool that does 1 thing well: **View CSV files**



## Open Source and Legacy

[Golumn](https://github.com/ddrscott/golumn) is open source. One day, someone other than myself can contribute to it. Someone other than myself could have the same impatience for CSV load times. Someone could have similar hotkey preferences. Or maybe not. I don't put it out there for fame or fortune. I but it out there because it's my favorite pet project and everyone should have a change to play with it. `Golumn` is buddy that has served me well for 7+ years, and I want it to have a home beyond me. History is made by sharing, not hoarding.

## Conclusion

Thanks for getting this far. I hope you find Golumn useful, and reach out to me if you have any questions or
suggestions. I'm always looking for ways to make it better.
