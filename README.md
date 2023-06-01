This is required by the hatcher cluster
=======================================

The `production` branch broke compatibility with hatcher once it merged
the pull request about [switching from docker to containerd][1]. If all
hatcher nodes switch from docker to containerd, they should be safe to
go back to `production`.

[1]: https://github.com/mlibrary/nebula/pull/582
