Introduction
------------

GoldDigger is a client-side browser plugin that allows a website to screenscrape or
interact with other websites, bypassing cross-domain restrictions. Once the plugin
is installed, the user can approve/deny individual websites' ability to do these
actions.

Because GoldDigger scrapes sites from the client side, websites need dramatically
less servers to do server-side scraping, fewer IP addresses to get blocked, no more 
ratelimits, no relying on often-crippled official APIs, no need for PCI Compliance
when using GoldDigger for financial applications, and many other extremely practical
benefits.

Some great use cases for GoldDigger:
- Competitor to Kayak/Orbitz/Hipmunk with access to more airlines
- Replacement for Mint.com without the need to give out your bank details to unknown sites
- A more user friendly interface to bank government and bank websites
- Price comparison and availability lookup for items at local stores
- Embedding live sports scores or financial information on your personal webpage

GoldDigger is currently only available for Chrome though obviously I'd like compatibility
on all major browsers.

Warning
-------

Gold Digger is in an extremely ALPHA state. Please don't start any startups based
on this plugin. :) It's currently lacking a lot of functionality.

Developer Example
-----------------
Include the following in your html page's `<head>`:

```html
<meta name='uses-gold-digger' content />
```

Execute the following in JavaScript on your webpage:

```javascript
goldDigger = GoldDigger.createScraper("http://www.google.com/finance?q=GOOG", failed, null, function (scraper) {
  scraper.waitFor("#price-panel span", function () {
    scraper.getDOM("#price-panel span", function (dom) {
      alert("The current live GOOG stock value is: " + dom.innerText.trim());
    })
  })
});
````

User accepts your webpage to access GoldDigger

![Permissions](http://github.com/lg/gold-digger/raw/master/examples/permissions.png)

Result on your own webpage:

![Google Finance](http://github.com/lg/gold-digger/raw/master/examples/google_finance.png)

Check out the `/examples` directory for more examples. Enjoy!

Installation
------------

1. Run `coffee --watch --compile .`
2. Load this directory as an unpacked extension in Google Chrome
3. Go to an example in the `/examples` directory

Feedback
--------

Please send your feedback to trivex@gmail.com or @lg on Twitter
