# This code is executed by the Background Page into every single page that
# Chrome loads. This needs to be done because there is no other way to detect
# if the page wishes to have GoldDigger abilities. Chrome is pretty fast these
# days and hopefully this extra javascript execution isn't noticeable.
#
# In order for the full communication injection to happen, the webpage needs
# the following meta tag present:
#   <meta name="uses-gold-digger" content />

if document.head && !!document.head.querySelector("meta[name='uses-gold-digger']")
  window.addEventListener 'message', (event) ->
    if event.data.goldDiggerRequest
      chrome.extension.sendMessage event.data.goldDiggerRequest, (response) ->
        window.postMessage {goldDiggerResponse: response, goldDiggerRequestId: event.data.goldDiggerRequestId}, "*"
