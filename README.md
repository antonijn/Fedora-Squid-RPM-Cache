# Fedora mirror db for Squid caching
[This post](https://serverfault.com/questions/837291/squid-and-caching-of-dnf-yum-downloads)
on serverfault shows a method of having Squid map URLs from different RPM mirrors
to the same underlying cache objects. It does not show a method of automatically
creating the database. This does that (for Fedora).

## Usage

```
$ ./squid-gen-db.sh > fedora.db
```

For mirrors which mirror stuff other than `$(uname -m)`:

```
$ for ARCH in x86_64 aarch64; do
>   ARCH=$ARCH ./squid-gen-db.sh
> done | sort -u > fedora.db
```
