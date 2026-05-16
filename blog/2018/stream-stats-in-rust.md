---
title: "A Rustic Journey Through Stream Stats"
date: 2018-03-17
created: 2018-03-17T00:00:00Z
type: blog
status: settled
tags: [rust]
publish: [ddrscott]
source: import
description: "How I made a CLI program in Rust which combines tee, wc -l, and watch."
image: /images/stream_stats_demo.png
prompt: "Import from blog post: 2018/stream-stats-in-rust.markdown"
---

# A Rustic Journey Through Stream Stats

<img class="featured" src="/images/stream_stats_demo.png" alt="Stream Stats Demo" />

After playing [Guessing Game](/blog/2018/getting-rusty-with-vim/) from the [Rust Book](https://doc.rust-lang.org/book/first-edition/guessing-game.html) a few times, it was time to make something a little more substantial. We're going to create `stream_stats`, a CLI program which prints throughput statistics from `stdin` while redirecting through `stdout`. Think `tee` + `wc -l` + `watch` all at the same time.

**TL;DR** - `cargo install stream_stats`

<!-- more -->

Here is a quick demo of the program:

<img src="/images/stream_stats_demo.gif" alt="Stream Stats Gif" />

Today, I we'll build this program up in 6 steps smallish steps. The minimum requirement of this program was the live feedback as seen in the demo _and_ minimal impact on the overall performance.

## Step 1 - Reproducing `cat` Inefficiently

First step is to replicate `cat`. We'll do it as demonstrated by Rust's own [documentation](https://doc.rust-lang.org/std/io/struct.Stdin.html#method.read_line).

```rust
use std::io;

fn main() {
    let mut buffer = String::new();
    while io::stdin().read_line(&mut buffer).unwrap() > 0 {
        print!("{}", buffer);
        buffer.clear();
    }
}
```
> I'm using `unwrap` to keep our program short and sweet.

Save the code as `stream_stats.rs` and build it using `rustc -O stream_stats.rs`. This will
compile the program into `stream_stats`. We can now run the program with
`./stream_stats < stream_stats.rs` or `cat stream_stats.rs | stream_stats`. This should output the source code we just wrote.

The program is sufficient for small streams, but will perform horribly on large files.

## Step 2 - Reproducing `cat` Efficiently with Buffering

> It can be excessively inefficient to work directly with a Read instance. For example, every call to read on TcpStream results in a system call. A BufReader performs large, infrequent reads on the underlying Read and maintains an in-memory buffer of the results.
>
> -- https://doc.rust-lang.org/std/io/struct.BufReader.html

Lets add some buffer use to increase performance and get it near the speed of `cat`. Replace the contents of `stream_stats.rs` with the following, recompile, and run the program.

```rust
use std::io::{self, BufRead, BufReader, BufWriter, Write};

static READ_BUF_SIZE: usize = 1024 * 1024;

fn main() {
    let mut reader = BufReader::with_capacity(READ_BUF_SIZE, io::stdin());
    let mut writer = BufWriter::new(io::stdout());
    let mut buffer = vec![];

    while reader.read_until(b'\n', &mut buffer).unwrap() > 0 {
        writer.write(&buffer).unwrap();
        buffer.clear();
    }
    writer.flush().unwrap();
}
```

The exact difference is <a href="https://github.com/ddrscott/tutorial-stream_stats/commit/30da32426f7ac420f4660c168678341301c68648" target="_new">viewable on Github</a>.
Here's a one-liner which to help with the build/run cycle:

```sh
rustc -O ./stream_stats.rs && ./stream_stats < stream_stats.rs
```

For a few extra lines, we get a lot of performance. There are ways to get even more
performance, but it won't be worth the code complexity at this time.

## Step 3 - Count the Lines

We're ready to start counting lines. We'll introduce a `struct` to hold a start
time and line count.

```rust
use std::io::{self, BufRead, BufReader, BufWriter, Write};
use std::time::Instant;

static READ_BUF_SIZE: usize = 1024 * 1024;

struct Stats {
    started: Instant,
    lines: usize,
}

fn main() {
    let mut reader = BufReader::with_capacity(READ_BUF_SIZE, io::stdin());
    let mut writer = BufWriter::new(io::stdout());
    let mut buffer = vec![];

    let mut stats = Stats {
        started: Instant::now(),
        lines: 0,
    };

    while reader.read_until(b'\n', &mut buffer).unwrap() > 0 {
        writer.write(&buffer).unwrap();
        stats.lines += 1;
        buffer.clear();
    }
    writer.flush().unwrap();
    eprintln!("lines: {}, {:?}", stats.lines, stats.started.elapsed());
}
```

Again the exact difference is <a href="https://github.com/ddrscott/tutorial-stream_stats/commit/4131ec8daea852ec4641cbca9ba13775ff8679d5?diff=split" target="_new">viewable on Github</a>.

## Step 4 - Write to `/dev/tty`

Using `eprintln!` is easy, but bad practice for non-error output. The next step is moving the output to `/dev/tty`. As a reminder, we're also not using `println!` because we're reserving it for the original content piped from `stdin`.

```rust
use std::fs::{File, OpenOptions};
use std::io::{self, BufRead, BufReader, BufWriter, Write};
use std::time::Instant;

static READ_BUF_SIZE: usize = 1024 * 1024;

struct Stats {
    started: Instant,
    lines: usize,
    tty: File,
}

impl Stats {
    fn new(tty: &str) -> Stats {
        Stats {
            started: Instant::now(),
            lines: 0,
            tty: OpenOptions::new()
                .write(true)
                .append(true)
                .open(tty)
                .expect("Cannot open tty for writing!"),
        }
    }
}

fn main() {
    let mut reader = BufReader::with_capacity(READ_BUF_SIZE, io::stdin());
    let mut writer = BufWriter::new(io::stdout());
    let mut buffer = vec![];
    let mut stats = Stats::new("/dev/tty");

    while reader.read_until(b'\n', &mut buffer).unwrap() > 0 {
        writer.write(&buffer).unwrap();
        stats.lines += 1;
        buffer.clear();
    }
    writer.flush().unwrap();
    writeln!(
        stats.tty,
        "lines: {}, {:?}",
        stats.lines,
        stats.started.elapsed()
    ).expect("Could not write to tty!");
}
```

Exact difference is <a href="https://github.com/ddrscott/tutorial-stream_stats/commit/e15502b23c1428f5ff86fdf6c6d791221e456992?diff=split" target="_new">viewable on Github</a>.

## Step 5 - Beautify Stats Output

The display logic is going to get a little more complex. We want to move the string formatting code to a `fmt::Display` trait. We'll also add the kilobytes to the displayed stats.

```rust
use std::fmt;
use std::fs::{File, OpenOptions};
use std::io::{self, BufRead, BufReader, BufWriter, Write};
use std::time::Instant;

static READ_BUF_SIZE: usize = 1024 * 1024;
static CLEAR_LINE: &str = "\x1B[1G\x1B[2K";

struct Stats {
    started: Instant,
    lines: usize,
    bytes: usize,
    tty: File,
}

impl Stats {
    fn new(tty: &str) -> Stats {
        Stats {
            started: Instant::now(),
            lines: 0,
            bytes: 0,
            tty: OpenOptions::new()
                .write(true)
                .append(true)
                .open(tty)
                .expect("Cannot open tty for writing!"),
        }
    }
}

impl fmt::Display for Stats {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {

        let elapsed = self.started.elapsed();
        let seconds: f64 = elapsed.as_secs() as f64 + elapsed.subsec_nanos() as f64 * 1e-9;
        if seconds == 0.0 {
            return write!(f, "");
        }
        let kb = self.bytes as f64 / 1024 as f64;
        let kb_per_sec = kb / seconds;
        let lines_per_sec = self.lines as f64 / seconds;
        write!(
            f,
            "{}{:.1} sec | {:.0} kb [ {:.1}/s ] | {} lines [ {:.0}/s ]",
            CLEAR_LINE,
            seconds,
            kb,
            kb_per_sec,
            self.lines,
            lines_per_sec
        )
    }
}

fn main() {
    let mut reader = BufReader::with_capacity(READ_BUF_SIZE, io::stdin());
    let mut writer = BufWriter::new(io::stdout());
    let mut buffer = vec![];
    let mut stats = Stats::new("/dev/tty");

    while reader.read_until(b'\n', &mut buffer).unwrap() > 0 {
        writer.write(&buffer).unwrap();
        stats.lines += 1;
        stats.bytes += &buffer.len();
        buffer.clear();
    }
    writer.flush().unwrap();
    writeln!(&stats.tty, "{}", &stats).expect("Could not write to tty!");
}
```

Exact difference is <a href="https://github.com/ddrscott/tutorial-stream_stats/commit/d2c5ef1cfcffc6a54e4b669aae835051d262143d?diff=split" target="_new">viewable on Github</a>.


## Step 6 - Display the stats 10 times per second

We're finally at the most useful part of the program. Viewing the stats while
the stream is still going.

For this task, we introduce a thread which loops forever sleeping a little and
waking to output the stats. Because of the thread, we need to use `Arc` to
safely tell Rust another thread is going to have a pointer to the stats object.

To be honest, I don't fully understand why I need to use `AtomicUsize`. I tried
to keep the `usize` variables would get errors regarding mutability. If someone
out there can remove the `AtomicUsize` without introducing `unsafe` please let
me know!

Here's the final code listing:

```rust
use std::fmt;
use std::fs::{File, OpenOptions};
use std::io::{self, BufRead, BufReader, BufWriter, Write};
use std::sync::Arc;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::thread::{self, sleep};
use std::time::{Duration, Instant};

static READ_BUF_SIZE: usize = 1024 * 1024;
static CLEAR_LINE: &str = "\x1B[1G\x1B[2K";
static UPDATE_INTERVAL_MS: u64 = 100;

struct Stats {
    started: Instant,
    lines: AtomicUsize,
    bytes: AtomicUsize,
    tty: File,
}

impl Stats {
    fn new(tty: &str) -> Stats {
        Stats {
            started: Instant::now(),
            lines: AtomicUsize::new(0),
            bytes: AtomicUsize::new(0),
            tty: OpenOptions::new()
                .write(true)
                .append(true)
                .open(tty)
                .expect("Cannot open tty for writing!"),
        }
    }

    fn add(&self, buffer: &Vec<u8>) {
        self.lines.fetch_add(1, Ordering::Relaxed);
        self.bytes.fetch_add(buffer.len(), Ordering::Relaxed);
    }
}

impl fmt::Display for Stats {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {

        let elapsed = self.started.elapsed();
        let seconds: f64 = elapsed.as_secs() as f64 + elapsed.subsec_nanos() as f64 * 1e-9;
        if seconds == 0.0 {
            return write!(f, "");
        }
        let bytes = self.bytes.load(Ordering::Relaxed) as f64;
        let lines = self.lines.load(Ordering::Relaxed) as f64;
        let kb = bytes / 1024 as f64;
        let kb_per_sec = kb / seconds;
        let lines_per_sec = lines / seconds;
        write!(
            f,
            "{}{:.1} sec | {:.0} kb [ {:.1}/s ] | {:.0} lines [ {:.0}/s ]",
            CLEAR_LINE,
            seconds,
            kb,
            kb_per_sec,
            lines,
            lines_per_sec
        )
    }
}

fn main() {
    let mut reader = BufReader::with_capacity(READ_BUF_SIZE, io::stdin());
    let mut writer = BufWriter::new(io::stdout());
    let mut buffer = vec![];
    let stats = Arc::new(Stats::new("/dev/tty"));

    let stats_clone = stats.clone();
    thread::spawn(move || loop {
        sleep(Duration::from_millis(UPDATE_INTERVAL_MS));
        write!(&stats_clone.tty, "{}", &stats_clone).expect("Could not write to tty!");
    });

    while reader.read_until(b'\n', &mut buffer).unwrap() > 0 {
        writer.write(&buffer).unwrap();
        stats.add(&buffer);
        buffer.clear();
    }
    writer.flush().unwrap();
    writeln!(&stats.tty, "{}", &stats).expect("Could not write to tty!");
}
```

Exact difference is <a href="https://github.com/ddrscott/tutorial-stream_stats/commit/e0b51a9de1364bfe3becfac8b27040c62bf06ac2?diff=split" target="_new">viewable on Github</a>.

## Closing Thoughts

I personally learned a lot assembling these steps and wish I did this _before_
publishing the `cargo` [crate](https://github.com/ddrscott/stream_stats) of the same name.

Any suggestions, comments, and corrections welcome on this post or the final crate are welcome.
https://github.com/ddrscott/stream_stats

Thanks for learning with me!
