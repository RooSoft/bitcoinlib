# Bitcoin for Elixir beginners

So, you're new to Elixir and want to try this lib out? Don't worry, we've got you covered. 
There are no requirements whatsoever to be able to do the following maybe other than:

- Knowing how to get into a shell
- Be able to install some software
- Have basic knowledge of programming.


## Prerequisite

Open a shell.

Make sure Elixir is installed by typing the following:

```bash
iex
```

If the shell answers with a prompt similar to this one...

```
Erlang/OTP 24 [erts-12.3.2] [source] [64-bit] [smp:10:10] [ds:10:10:10] [async-threads:1] [dtrace]

Interactive Elixir (1.13.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

... then you're good to go. Hit `ctrl-c` twice to exit it and go to the next step.

Otherwise, [install it](https://elixir-lang.org/install.html) and try the above test again.

## Create a project

To use the library, you'll need at the very least to create a new Elixir project. First go to
any working folder of your choice and enter this command

```bash
mix new tutorial
```

where `tutorial` is the name of the project and can be changed. The command should reward you with
green output about some file creation. Now go on and move to the project's folder by typing

```bash
cd tutorial
```

## Add BitcoinLib as a dependency

Open the `mix.exs` file in an editor and look for the `deps` section, it should look like this

```elixir
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
```

Get rid of the examples and add `BitcoinLib` to the dependencies, so it ends up looking like this

```elixir
  defp deps do
    [
      {:bitcoinlib, "~> 0.1.0"}
    ]
  end
```

Just make sure the version number matches the [latest release](https://github.com/RooSoft/bitcoinlib/releases).

## Update dependencies

Now that your project knows it depends on BitcoinLib, make sure it downloads the code, so the lib
becomes usable, by issuing this command

```bash
mix deps.get
```

## Start an Elixir shell

It is now possible to open a shell in which BitcoinLib is directly usable by typing this

```bash
iex -S mix
```

This command will send some compilation output to the shell if not already done, and then issue
a prompt that now should look familiar

```
Erlang/OTP 24 [erts-12.1] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]

Interactive Elixir (1.13.4) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)>
```

From now on, and until you type `ctrl-c` twice to get out, you'll be able to use the library.

Let's move on and [create a private key](/docs/tutorial/private_key.md).