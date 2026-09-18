
# valk-cli

Command line parsing for [Valk](https://valk-lang.dev): options, subcommands, arguments, and the
help text that goes with them. Purely written in Valk, with no os-package dependencies.

Requires Valk 0.7.0 or newer.

## Install

```
vman install github.com/ctxcode/valk-cli
```

## Example

```rust
use cli

fn main(args: Array[String]) {
    let app = cli.App.new("greet", "Greet someone", "1.0.0")
    app.root.option("times", "n", "How often to greet", "1")
    app.root.flag("loud", "l", "Greet in capitals")
    app.root.argument("name", "Who to greet", true)
    app.root.on_run(fn(ctx: cli.Context) i32 !cli.Error {
        let times = ctx.int("times", 1) !>
        let i: int = 0
        while i++ < times {
            let line = "Hello " + ctx.arg("name") + "!"
            println(ctx.flag("loud") ? line.upper() : line)
        }
        return 0
    })
    exit(app.run(args))
}
```

```
$ greet Ada -n 2 --loud
HELLO ADA!
HELLO ADA!
```

`run` reads the command line, runs the command it names, and returns what the program should
exit with: what your handler returned, 0 after `--help` or `--version`, and 2 when the command
line could not be read.

## What it reads

The forms every unix tool takes:

```
--output file      --output=file      -o file      -ofile
--verbose          -v                 -vq          (switches written together)
--                 everything after this is a value, `-x` and all
-                  a value on its own, as tools read it for standard input
```

Values that are not written behind a name are handed to the arguments in order, wherever they
appear on the line: `tool one.txt --verbose two.txt` gives `one.txt` and `two.txt` to the
arguments and turns the switch on.

## Options, switches and arguments

```rust
app.root.flag("verbose", "v", "Say more")                        // --verbose / -v
app.root.option("output", "o", "Where to write", "out.txt")      // --output <value>, with a default
app.root.argument("source", "What to read", true)                // <source>, required
app.root.argument("extra", "More files", false, true)            // [extra...], takes the rest
```

An option can also be required, repeatable, limited to a set of values, and read from the
environment when it is not given:

```rust
app.root.option("include", "I", "A directory to search", "", "dir", "", false, true)
app.root.option("mode", "m", "How to run", "fast", "mode", "", false, false, .{ "fast", "slow" })
app.root.option("token", "t", "The API token", "", "token", "TOOL_TOKEN", true)
app.root.flag("debug", "d", "Say more", "TOOL_DEBUG")
```

What is typed wins over the environment, which wins over the default.

## Reading what was given

```rust
ctx.flag("verbose")            // whether a switch was given
ctx.has("output")              // whether an option was given a value
ctx.value("output")            // the value, else the environment, else the default
ctx.values("include")          // every value of a repeatable option
ctx.int("times", 1) !>         // the value as a number; `invalid_value` when it is not one
ctx.float("ratio", 1.0) !>
ctx.arg("source")              // an argument by name
ctx.args("extra")              // every value of a variadic argument
ctx.rest                       // whatever followed `--`
```

## Subcommands

A command holds commands of its own, as deep as you like:

```rust
let remote = cli.Command.new("remote", "Work with remotes")
let add = cli.Command.new("add", "Add a remote")
add.argument("name", "Its name", true)
add.argument("url", "Where it lives", true)
add.on_run(fn(ctx: cli.Context) i32 !cli.Error {
    println("added " + ctx.arg("name"))
    return 0
})
remote.command(add)
app.root.command(remote)
```

`vcs remote add origin git@example.com:repo.git` then runs that handler, and
`vcs remote add --help` prints its help. A command with subcommands and no handler of its own
prints its help and exits 1, which is what a bare `vcs remote` should do.

## Help and errors

`--help` and `-h` print the help of the command they follow; `--version` prints the version.
Both are added for you. The help of a command lists its commands, arguments and options with
their defaults, choices and environment variables.

An error names what went wrong, and offers the nearest thing when something was mistyped:

```
$ greet helo Ada
error: Unknown command 'helo'. Did you mean 'hello'?

Usage:
  greet [options] <command>

Run 'greet --help' to see what it takes.
```

Colours follow the terminal and are off when `NO_COLOR` is set; `cli.colors = false` turns them
off by hand. `app.out` and `app.errors` are where the text goes, standard output and standard
error by default, so a test can collect them in a `ByteBuffer`.

Your handler throws `cli.Error` for anything the person typed wrong, which is printed the same
way as the errors above:

```rust
if times < 1 : throw .invalid_value { message: "--times takes a number above zero", command: ctx.command.path() }
```

## Tab completion

`app.add_completion_command()` adds a `completion` command that prints the script for a shell:

```sh
mytool completion bash > /etc/bash_completion.d/mytool
mytool completion zsh  > ~/.zfunc/_mytool          # a directory on your fpath
mytool completion fish > ~/.config/fish/completions/mytool.fish
```

The script is a few lines that ask the program itself what to offer, through a hidden
`__complete` command. Nothing about your commands is written into the script, so it never has to
be regenerated when you add a command, an option or a value — the completions always match the
program that is installed.

Out of the box it completes subcommands, long and short option names, and the values of an
option that has `choices`, including the `--name=value` form. For values that are only known at
runtime, give the option or the argument a function:

```rust
deploy.option("environment", "e", "Where to deploy to")
deploy.complete_option("environment", fn(words: Array[String]) Array[String] {
    return read_environments(words)      // the words typed so far, if they matter
})

deploy.argument("service", "Which service", true)
deploy.complete_argument("service", fn(words: Array[String]) Array[String] {
    return services_in_the_config()
})
```

Where the program offers nothing, bash and zsh fall back to completing file names, so
`--output <tab>` behaves as a shell user expects.

`app.complete(words)` is the same answer as a value, so what a shell will offer can be asserted
in a test without a shell:

```rust
assert(app.complete(.{ "mytool", "remote", "--" }).contains("--help"))
```

## Reading without running

`app.parse(args)` returns the `Context` without running anything, for a program that answers by
itself or a test that checks what a command line means:

```rust
let ctx = app.parse(.{ "tool", "--output", "a.txt", "in.txt" }) ! panic("%{E.message}")
assert(ctx.value("output") == "a.txt")
```

## Errors

| code | when |
| --- | --- |
| `unknown_flag` | an option the command does not have |
| `unknown_command` | a subcommand that does not exist |
| `missing_value` | an option that takes a value was given none |
| `missing_argument` | a required argument or option was left out |
| `invalid_value` | not a number where one is expected, or not one of the choices |
| `usage` | the command line could not be read for another reason |

## Development

`make test` runs the suite, `make example` builds the example and prints its help, `make lint`
checks the sources and `make docs` regenerates the API documentation. Override the compiler with
`make vc=/path/to/valk test`.
