Introduction
------------

GoldDigger is a client-side browser plugin that allows a website to request
permissions to read/write to other websites (bypassing cross-domain restrictions).

For example, GoldDigger could be used to build a new Mint.com that doesnt need you
to send your banking username/password to some possibly-insecure website. All
sensitive user data can now be stored locally and scraping is also local.

GoldDigger can also dramatically lower infrastructure costs since scraping is done
on the client side. Costs will be lowered for everything from servers needing to
actually scrape, to also not needing things like PCI compliance.

GoldDigger creates a read/write API for access to every website on the internet.


Possible uses for GoldDigger-powered sites
------------------------------------------

- Competitor to Kayak/Orbitz/Hipmunk with fares from all airlines, including tiny ones
- Replacement for Mint.com
- A nicer, more feature-ful alternative to banks' websites, government websites, etc
- Facilitate making internal bank transfers, money transactions, etc without a complex ui
- Track credit card balances between multiple banks
- Notifier for when credit cards are due
- Auto search for products on Amazon, eBay, local stores and sort them
- Aggregate multiple Twitter accounts on one screen
- Embed things like sports scores as a small widget on your page
- Embed your iPhone app's rating and comments automatically on your page


Installation
------------

1. Run `coffee --watch --compile .`
2. Load this directory as an unpacked extension in Google Chrome

