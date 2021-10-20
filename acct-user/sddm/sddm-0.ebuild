# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="System user; sddm"
ACCT_USER_ID=666
ACCT_USER_GROUPS=( sddm video)
ACCT_USER_HOME=/var/lib/sddm
ACCT_USER_HOME_PERMS=0700
ACCT_USER_SHELL=/sbin/nologin
acct-user_add_deps
SLOT="0"
