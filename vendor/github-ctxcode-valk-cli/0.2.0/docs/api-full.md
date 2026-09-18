
# Documentation

Namespaces: [main](#main)

---

# main

## Errors for 'main'

```js
// Thrown while the command line is read.
+ error Error (unknown_flag, unknown_command, missing_value, missing_argument, invalid_value, usage) payload { message: String, command: String ("") }
```

### Error

Thrown while the command line is read.

- `unknown_flag`: an option the command does not have.
- `unknown_command`: a subcommand that does not exist.
- `missing_value`: an option that takes a value was given none.
- `missing_argument`: a required argument or option was left out.
- `invalid_value`: a value that is not a number where one is expected, or not one of the
  choices an option allows.
- `usage`: the command line could not be read for another reason.

`message` is written for the person who typed the command, and `command` names the command
that was being read, so the usage line can be printed with it.

## Enums for 'main'

```js
// The shells that can be taught to complete a program.
+ enum Shell { bash, zsh, fish }
```

### Shell

The shells that can be taught to complete a program.

## Functions for 'main'

```js
// Returns the help text of a command: what it does, how it is used, and every command, option and argument it has.
+ fn help_text(command: Command, version: String ("")) String
```

### help_text

Returns the help text of a command: what it does, how it is used, and every command, option
and argument it has.

## Classes for 'main'

```js
// A program: its root command, and the running of it.
+ class App {
    // Where errors go. Standard error by default.
    + errors: Writer
    // Where the help text goes. Standard output by default.
    + out: Writer
    // The command the program itself is.
    + root: Command
    // The version, shown by `--version`.
    + version: String

    // Adds a `completion` command, which prints the script for the shell it is given.
    + fn add_completion_command(name: String ("completion")) App
    // Returns what a shell should offer for `words`, the command line up to the cursor.
    + fn complete(words: Array[String]) Array[String]
    // Returns the script that teaches `shell` to complete this program.
    + fn completion_script(shell: Shell) String
    // Returns the help text of the root command.
    + fn help() String
    // Creates a program with a root command of the same name.
    + static fn new(name: String, summary: String (""), version: String ("")) App
    // Reads the command line without running anything, for a program that answers by itself.
    + fn parse(args: Array[String]) Context !Error
    // Reads the command line and runs the command it names.
    + fn run(args: Array[String]) i32
}
```

### App

A program: its root command, and the running of it.

```valk
use cli

fn main(args: Array[String]) {
    let app = cli.App.new("greet", "Greet someone", "1.0.0")
    app.root.option("times", "n", "How often to greet", "1")
    app.root.argument("name", "Who to greet", true)
    app.root.on_run(fn(ctx: cli.Context) i32 !cli.Error {
        let times = ctx.int("times", 1) !>
        let i: uint = 0
        while i++ < times.to(uint) : println("Hello " + ctx.arg("name"))
        return 0
    })
    exit(app.run(args))
}
```

#### errors

Where errors go. Standard error by default.

#### out

Where the help text goes. Standard output by default.

#### root

The command the program itself is.

#### version

The version, shown by `--version`.

#### add_completion_command

Adds a `completion` command, which prints the script for the shell it is given.

```valk
app.add_completion_command()
// mytool completion bash >> ~/.bashrc
```

#### complete

Returns what a shell should offer for `words`, the command line up to the cursor.

The first word is the program, and the last is the word being completed, empty when the
cursor is after a space. This is what the `__complete` command answers with, and it is
what a test can check without a shell.

```valk
assert(app.complete(.{ "vcs", "remote", "--" }).contains("--help"))
```

#### completion_script

Returns the script that teaches `shell` to complete this program.

The script is a few lines that ask the program itself what to offer, so it never has to
be written again when a command or an option is added.

```sh
mytool completion bash > /etc/bash_completion.d/mytool     # or source it from .bashrc
mytool completion zsh  > ~/.zfunc/_mytool
mytool completion fish > ~/.config/fish/completions/mytool.fish
```

#### help

Returns the help text of the root command.

#### new

Creates a program with a root command of the same name.

#### parse

Reads the command line without running anything, for a program that answers by itself.

#### run

Reads the command line and runs the command it names.

Returns what the program should exit with: what the command returned, 0 after help or the
version, and 2 when the command line could not be read, which is what a shell expects for
a usage error.

`args` is what `main` is given, the program path first.

```js
// A value that is not written behind a name: `mytool build <target>`.
+ class Argument {
    // Lists the values a shell should offer for this argument, given the words typed so far.
    + complete: ?fn(Array[String])(Array[String])
    // One line for the help text.
    + help: String
    // The name, used in the usage line and to read the value.
    + name: String
    // Whether leaving it out is an error.
    + required: bool
    // Whether it takes everything that is left, as `<files...>` does.
    + variadic: bool
}
```

### Argument

A value that is not written behind a name: `mytool build <target>`.

#### complete

Lists the values a shell should offer for this argument, given the words typed so far.

#### help

One line for the help text.

#### name

The name, used in the usage line and to read the value.

#### required

Whether leaving it out is an error.

#### variadic

Whether it takes everything that is left, as `<files...>` does.

```js
// One command: its options, its arguments, what it does, and the commands under it.
+ class Command {
    // The arguments of this command, in the order they are read.
    ~ arguments: Array[Argument]
    // The commands under this one.
    ~ commands: Array[Command]
    // The longer text, shown under the usage line of this command's help.
    + description: String
    // The switches of this command.
    ~ flags: Array[Flag]
    // The name as it is typed.
    + name: String
    // The options of this command.
    ~ options: Array[Option]
    // The command this one sits under, or null for the root.
    ~ parent: ?Command
    // What the command does, returning the exit code of the program. A command without one prints its help.
    + run: ?fn(Context)(i32 !Error)
    // One line, shown in the list of commands.
    + summary: String

    // Adds an argument. A variadic one takes everything that is left and must come last.
    + fn argument(name: String, help: String (""), required: bool (false), variadic: bool (false)) Command
    // Adds a command under this one.
    + fn command(sub: Command) Command
    // Says what a shell should offer for an argument, the way `complete_option` does.
    + fn complete_argument(name: String, values: fn(Array[String])(Array[String])) Command
    // Says what a shell should offer as the value of an option.
    + fn complete_option(long: String, values: fn(Array[String])(Array[String])) Command
    // Returns the command with this name, or null.
    + fn find(name: String) ?Command
    // Returns the switch with this long name, or null.
    + fn find_flag(long: String) ?Flag
    // Returns the option with this long name, or null.
    + fn find_option(long: String) ?Option
    // Adds a switch, which is either given or not.
    + fn flag(long: String, short: String (""), help: String (""), env: String ("")) Command
    // Creates a command.
    + static fn new(name: String, summary: String ("")) Command
    // Sets what the command does. It returns the exit code of the program.
    + fn on_run(handler: fn(Context)(i32 !Error)) Command
    // Adds an option that takes a value.
    + fn option(long: String, short: String (""), help: String (""), default: String (""), placeholder: String ("value"), env: String (""), required: bool (false), repeated: bool (false), choices: Array[String] (.{})) Command
    // Returns the names of this command and the ones above it: `mytool remote add`.
    + fn path() String
    // Returns the `Usage:` line of this command.
    + fn usage() String
}
```

### Command

One command: its options, its arguments, what it does, and the commands under it.

A program is a tree of these. The root command is the program itself, and a subcommand is a
command of its own with a name, its own options and possibly commands under it again.

```valk
let build = cli.Command.new("build", "Compile the project")
build.flag("release", "r", "Build with optimizations")
build.option("output", "o", "Where to write the binary", "./app")
build.argument("target", "What to build", false)
build.on_run(fn(ctx: cli.Context) i32 !cli.Error {
    println("building " + ctx.arg("target", "everything"))
    return 0
})
```

#### arguments

The arguments of this command, in the order they are read.

#### commands

The commands under this one.

#### description

The longer text, shown under the usage line of this command's help.

#### flags

The switches of this command.

#### name

The name as it is typed.

#### options

The options of this command.

#### parent

The command this one sits under, or null for the root.

#### run

What the command does, returning the exit code of the program. A command without one
prints its help.

#### summary

One line, shown in the list of commands.

#### argument

Adds an argument. A variadic one takes everything that is left and must come last.

#### command

Adds a command under this one.

#### complete_argument

Says what a shell should offer for an argument, the way `complete_option` does.

#### complete_option

Says what a shell should offer as the value of an option.

The function is given the words typed so far and returns the candidates. An option with
`choices` needs none of this: those are offered as they are.

```valk
deploy.option("environment", "e", "Where to deploy to")
deploy.complete_option("environment", fn(words: Array[String]) Array[String] {
    return read_environments_from_the_config()
})
```

#### find

Returns the command with this name, or null.

#### find_flag

Returns the switch with this long name, or null.

#### find_option

Returns the option with this long name, or null.

#### flag

Adds a switch, which is either given or not.

#### new

Creates a command.

#### on_run

Sets what the command does. It returns the exit code of the program.

#### option

Adds an option that takes a value.

#### path

Returns the names of this command and the ones above it: `mytool remote add`.

#### usage

Returns the `Usage:` line of this command.

```js
// What the command line said, ready to be read by the command that runs.
+ class Context {
    // The command that is running.
    + command: Command
    // Whether `--help` or `-h` was written.
    ~+ help_asked: bool
    // The program name as it was typed, which is the first item of the command line.
    + program: String
    // Whatever followed a `--`, handed on untouched.
    ~ rest: Array[String]
    // Whether `--version` was written.
    ~+ version_asked: bool

    // Returns an argument by name, or `fallback` when it was not given.
    + fn arg(name: String, fallback: String ("")) String
    // Returns every value of a variadic argument, in order.
    + fn args(name: String) Array[String]
    // Returns whether a switch was given, or its environment variable is on.
    + fn flag(long: String) bool
    // Returns the value of an option as a number.
    + fn float(long: String, fallback: float (0)) float !Error
    // Returns whether an option was given a value, on the command line or through its environment variable.
    + fn has(long: String) bool
    // Returns whether an argument was given.
    + fn has_arg(name: String) bool
    // Returns the value of an option as a whole number.
    + fn int(long: String, fallback: int (0)) int !Error
    // Returns the value of an option: what was given, else its environment variable, else its default, else `fallback`.
    + fn value(long: String, fallback: String ("")) String
    // Returns every value an option was given, for one that may be repeated.
    + fn values(long: String) Array[String]
}
```

### Context

What the command line said, ready to be read by the command that runs.

```valk
build.on_run(fn(ctx: cli.Context) i32 !cli.Error {
    if ctx.flag("verbose") : println("building " + ctx.arg("target", "everything"))
    let jobs = ctx.int("jobs", 1) !>
    each ctx.rest as passed_through : println("extra: " + passed_through)
    return 0
})
```

#### command

The command that is running.

#### help_asked

Whether `--help` or `-h` was written.

#### program

The program name as it was typed, which is the first item of the command line.

#### rest

Whatever followed a `--`, handed on untouched.

#### version_asked

Whether `--version` was written.

#### arg

Returns an argument by name, or `fallback` when it was not given.

#### args

Returns every value of a variadic argument, in order.

#### flag

Returns whether a switch was given, or its environment variable is on.

#### float

Returns the value of an option as a number.

#### has

Returns whether an option was given a value, on the command line or through its
environment variable.

#### has_arg

Returns whether an argument was given.

#### int

Returns the value of an option as a whole number.

Throws `invalid_value` when the text is not a number, naming the option.

#### value

Returns the value of an option: what was given, else its environment variable, else its
default, else `fallback`.

#### values

Returns every value an option was given, for one that may be repeated.

```js
// A switch: `--verbose`, or `-v`. It takes no value, and is either given or not.
+ class Flag {
    // An environment variable that turns the flag on when it is `1`, `true`, `yes` or `on`.
    + env: String
    // One line for the help text.
    + help: String
    // The long name, written as `--name`.
    + long: String
    // The single letter form, written as `-n`, or "" when it has none.
    + short: String
}
```

### Flag

A switch: `--verbose`, or `-v`. It takes no value, and is either given or not.

#### env

An environment variable that turns the flag on when it is `1`, `true`, `yes` or `on`.

#### help

One line for the help text.

#### long

The long name, written as `--name`.

#### short

The single letter form, written as `-n`, or "" when it has none.

```js
// An option that takes a value: `--output file`, `--output=file`, or `-o file`.
+ class Option {
    // The values the option allows, or empty when anything goes.
    + choices: Array[String]
    // Lists the values a shell should offer for this option, given the words typed so far. `choices` are offered without one.
    + complete: ?fn(Array[String])(Array[String])
    // The value used when the option is not given.
    + default: String
    // An environment variable read when the option is not given.
    + env: String
    // One line for the help text.
    + help: String
    // The long name, written as `--name`.
    + long: String
    // The word for the value in the help text, such as `file` in `--output <file>`.
    + placeholder: String
    // Whether it may be given several times, collecting every value.
    + repeated: bool
    // Whether leaving it out is an error.
    + required: bool
    // The single letter form, written as `-n`, or "" when it has none.
    + short: String
}
```

### Option

An option that takes a value: `--output file`, `--output=file`, or `-o file`.

#### choices

The values the option allows, or empty when anything goes.

#### complete

Lists the values a shell should offer for this option, given the words typed so far.
`choices` are offered without one.

#### default

The value used when the option is not given.

#### env

An environment variable read when the option is not given.

#### help

One line for the help text.

#### long

The long name, written as `--name`.

#### placeholder

The word for the value in the help text, such as `file` in `--output <file>`.

#### repeated

Whether it may be given several times, collecting every value.

#### required

Whether leaving it out is an error.

#### short

The single letter form, written as `-n`, or "" when it has none.

## Globals for 'main'

```js
// Whether help and error text is written with colours. It follows the terminal by default, and `NO_COLOR` turns it off.
+ global colors : bool
```

### colors

Whether help and error text is written with colours. It follows the terminal by default, and
`NO_COLOR` turns it off.
