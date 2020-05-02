Security Guide
==============

Threat Model
------------

Remember: Nothing is perfectly secure, and an adversary with sufficient resources can always penetrate a system.

We do assume that adversaries are performing passive surveillance and, possibly, active man-in-the-middle attacks. And so:

* User credentials are always sent through SSH/TLS, never in the clear, with modern TLS settings. Therefore we automatically install LetsEncrypt even before we enter our credentials to finish the nextcloud installation.

Additional details follow.

Why do i have to enter DNS and admin's Mail address?
----------------------------------------------------

* This installer does use those information to obtain the LetsEncrypt certificate. We (the installer) does not store or transmit any data to other persons or organisations than LetsEncrpt.

* DNS of course is needed in order to get the apache config right.
