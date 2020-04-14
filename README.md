# What
Pre-built build environment for compiling x86_64-linux-musl.

# Running
Simply volume mount your directory into /data and run whatever compile command you were going to before. This container simply replaces the normal commands with versions for musl compile.

Here's an alias:

```bash
alias musl-cross-x86_64-linux="sudo docker run -it --rm -v $PWD:/data bannsec/musl-cross-x86_64-linux $@"
```

An example of using that would be:

```bash
cd my-project
musl-cross-x86_64-linux
./configure && make
```

# What's included

The following libraries are compiled and included by default:

| Library | Version |
| ------- | ------- |
| openssl | v1.1.1f |
| zlib    | v1.2.11 |
| bzip2   | v1.0.8  |
| libpcap | v1.9.1  |
| libgmp  | v6.2.0  |
| cmake   | v3.17.1 |

# Adding your own library

If you need a library not here, all you have to do is compile it yourself and set `--prefix /opt/cross`. It should mostly work fine from there.

## Custom FLAGS

Sometimes you may want to adjust different compile flags. Please note that some flags have been modified by this container to help make things more seamless. If you're going to modify a compiler variable, be sure to append rather than overwrite.

Example:

```bash
./configure CFLAGS="$CFLAGS -g"
```
