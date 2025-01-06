# This file is managed by puppet. It is the debian/ubuntu stock `.profile`,
# with no modification beyond this comment.
#
# Don't override this with .bash_profile, as it is automatically deleted.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n 2> /dev/null || true
