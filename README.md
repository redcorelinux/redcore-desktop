Redcore Linux desktop ebuilds. Mostly stable and safe to use :)

This overlay contains :

* home backed ebuilds, not found in Gentoo's portage tree, or any other overlay
* customized Gentoo ebuilds to better suit Redcore's needs (e.g. dkms integration)
* patched Gentoo ebuilds if the ones in portage tree are broken or they have missing dependencies (it happens)

Policy :

* The home backed ebuilds will sometimes lack behind upstream releases, we don't actively check for new upstream releases.
But don't worry, we will eventually update them, no ebuild in here is forgotten or unmaintained. Once we loose interest
in one particular ebuild we will simply drop it. We won't keep it in here just because somebody "MAY" eventually use it.  

* Customisation/patching of Gentoo ebuilds will be as minimal as possible. However sometimes we can go wild and completely 
change things, like adding/dropping USE flags, apply patches and so on. Most of our changes are USE flag conditional, so
the ebuilds can be used in upstream Gentoo without modification. All you will have to do, is disable our new USE flags.
In Redcore Linux the customised/patched ebuilds will always have priority, and we will apply masks to prevent Gentoo ones
from being pulled in.

* If our patched ebuilds can be submitted upstream, we will do so, and drop the corresponding ebuild in here, if accepted.
However this is not always the case, as sometimes we will not obey to Gentoo's QA standars. And most of the time we don't
even need to do so, as Gentoo folks are very good at solving issues. So if an ebuild just vanishes from in here, just use
the corresponding Gentoo one. It means our patches are no longer needed. 
