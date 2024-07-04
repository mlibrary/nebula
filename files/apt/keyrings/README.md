# apt keyrings

Files destined for /etc/apt/keyrings

Regenerate these files by running update.sh from this directory and running
`git status` or `git diff` to see what changed. These should rarely change.
They are cached here rather than automatically pulled on puppet runs to
protect against supply chain attacks in the event that one of the domains
these certs originate from changes hand in the future.
