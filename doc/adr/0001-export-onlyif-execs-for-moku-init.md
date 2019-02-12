1. Export `onlyif` execs for `moku init`
========================================

Date: 2019-02-08

Status
------

Accepted

Context
-------

Let's say we have ten applications (`app_1`, `app_2`, ..., `app_10`)
defined in hiera such that the deploy host can read them. Furthermore,
let's say we have named instances of some of them on four different
production hosts, like this:

```
                           +-------------+
                           | Deploy Host |
                           +-------------+

+-------------+   +-------------+   +-------------+   +-------------+
| App Host A: |   | App Host B: |   | App Host C: |   | App Host D: |
| - app_1     |   | - app_1     |   | - app_1     |   | - app_1     |
| - app_2     |   | - app_2     |   | - app_3     |   | - app_4     |
+-------------+   +-------------+   +-------------+   +-------------+
```

So only apps 1–4 are actually instantiated, and a couple of them are on
more than one host. In this setup, we need the deploy host to run `moku
init` once (and only once) for each of those four apps (and not at all
for the other apps which haven't yet been instantiated).

If the deploy host runs the command for each app it knows how to set up,
then it'll only run `init` once per app, but it'll run it for apps 5–10,
which we do not want it to do.

If the app hosts export `exec` resources, then, in this example, the
deploy host would find 4 of the same command for `app_1`, 2 for `app_2`,
and 1 each for `app_3` and `app_4`. It wouldn't find any for apps 5–10,
but it'd find too many for apps 1 and 2.

If the deploy host runs a puppetdb query to find all named instances to
get a list of unique instance names, then it will get a list of apps
1–4, which it could use to run `moku init` for each of them. This is the
desired behavior, but our experience with puppetdb queries is negative:
they are very hard to test, and they are very ugly and hard to read.

In addition to all this, the `moku init` command requires that a json
file exist on the deploy host for each application (based on its
hieradata).

Decision
--------

We will add a `moku stat` command which will return 0 if and only if
moku is ready to receive a `moku init`.

This way, we can use exported exec resources that use the `onlyif`
parameter, like this:

```
@@exec { "${title} ${::hostname} moku init":
  command => 'moku init',
  onlyif  => 'moku stat',
}
```

If `moku stat` exits with something other than 0, puppet will consider
this exec to be a success without actually running it. If `moku stat`
does exit with 0, then puppet will consider this to succeed if and only
if `moku init` succeeds.

As for the json files, we don't mind them existing even when they aren't
needed, so the deploy host can create them for every application
regardless of whether it exists yet.

Consequences
------------

Moku will need to be able to run moku stat in a way that prevents race
conditions, which can be delicate. Also, the more exported resources we
add, the more our need to figure out a way to test the catalogue
increases.

Moku will need to be able to handle many `moku stat` requests in a row
every half hour, forever.
