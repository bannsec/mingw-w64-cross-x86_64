# What
Pre-built build environment for cross compiling x86_64 with mingw-64

# Running
Simply volume mount your directory into /data and run whatever compile command you were going to before. This container simply replaces the normal commands with versions for mingw to compile.

Here's an alias:

```bash
alias mingw-w64-cross-x86_64='sudo docker run -it --rm -v $PWD:/data bannsec/mingw-w64-cross-x86_64 $@'
```

An example of using that would be:

```bash
cd my-project
mingw-w64-cross-x86_64
./configure && make
```

Or for a simple project

```bash
cd src
mingw-w64-cross-x86_64 make
```

# What's included

The following libraries are compiled and included by default:

| Library | Version |
| ------- | ------- |
| openssl | v1.1.1f |
| zlib    | v1.2.11 |
| bzip2   | v1.0.8  |
| libgmp  | v6.2.0  |

# Adding your own library

If you need a library not here, all you have to do is compile it yourself and set `--prefix /opt/cross`. It should mostly work fine from there.

## Custom FLAGS

Sometimes you may want to adjust different compile flags. Please note that some flags have been modified by this container to help make things more seamless. If you're going to modify a compiler variable, be sure to append rather than overwrite.

Example:

```bash
./configure CFLAGS="$CFLAGS -Os" CXXFLAGS="$CXXFLAGS -Os"
```

# Compiler errors?

## Defining --host
If there are common issues that have been worked through previously by the authors, they may already have a fix for you. Try adding the flag `--host=x86_64-pc-mingw64` to your `./configure` line.

## ./a.exe not running
If you get an error from `./configure` about `a.exe` or similar not being able to run, you might need to install `wine` and add it's binfmt to your kernel to allow you to `./a.exe`.

```bash
sudo docker run -it --rm --privileged bannsec/mingw-w64-cross-x86_64 update-binfmts --enable wine
```
