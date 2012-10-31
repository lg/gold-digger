# This code is executed by the Background Page into any webpage that
# requires GoldDigger abilities. It provides a proxy between that webpage
# and the Background Page (which then connects requests to individual tabs
# for scraping purposes)

window.addEventListener 'message', (event) ->
  if event.data.goldDiggerRequest
    chrome.extension.sendMessage event.data.goldDiggerRequest, (response) ->
      window.postMessage {goldDiggerResponse: response, goldDiggerRequestId: event.data.goldDiggerRequestId}, "*"
