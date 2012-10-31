# TODO: fail fast if the dom is fully loaded, yet the selector can't be found
# TODO: allow more than just freeflight.html

@GoldDiggerScraper = class GoldDiggerScraper
  @createScraper: (url, identifierCb) ->
    chrome.tabs.create {url: url, selected: false}, (tab) ->
      identifierCb tab.id

  @exec: (identifier, code, resultCb) ->
    result = null
    requestId = Math.floor(Math.random() * 10000000000)
    responseCb = (response, sender, sendResponse) ->
      if response['requestId'] == requestId.toString()
        result = response['result']
    chrome.extension.onRequest.addListener responseCb
    chrome.tabs.executeScript identifier, {code: "result = #{code}; chrome.extension.sendRequest({requestId: '#{requestId}', result: result});"}, ->
      chrome.extension.onRequest.removeListener responseCb
      resultCb result

chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) ->
  if changeInfo.status == "complete" && /freeflight\.html/i.test(tab.url)
    chrome.tabs.executeScript tabId, {file: "proxy.js"}

chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
  if request.command == "ping"
    sendResponse "pong"
  else if request.command == "exec"
    GoldDiggerScraper.exec request.args.pageId, request.args.code, (result) ->
      sendResponse result
    return true
  else if request.command == "createScraper"
    GoldDiggerScraper.createScraper request.args.url, (result) ->
      sendResponse result
    return true
  return false
