# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2025 Redcore Linux Project
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit redcore-kernel

KEYWORDS="~amd64"

PATCHES=(
	"${FILESDIR}"/"${KV_MAJOR}"-ath10k-be-quiet.patch
	"${FILESDIR}"/"${KV_MAJOR}"-ata-fix-NCQ-LOG-strings-and-move-to-debug.patch
	"${FILESDIR}"/"${KV_MAJOR}"-acpi-use-kern_warning_even_when_error.patch
	"${FILESDIR}"/"${KV_MAJOR}"-fix-bootconfig-makefile.patch
	"${FILESDIR}"/"${KV_MAJOR}"-apic_vector-spam-in-debug-mode-only.patch
	"${FILESDIR}"/"${KV_MAJOR}"-0001-Revert-cpufreq-Avoid-configuring-old-governors-as-de.patch
	"${FILESDIR}"/"${KV_MAJOR}"-revert-parts-of-a00ec3874e7d326ab2dffbed92faddf6a77a84e9-no-Intel-NO.patch
	"${FILESDIR}"/"${KV_MAJOR}"-ZEN-Add-sysctl-and-CONFIG-to-disallow-unprivileged-C.patch
)
