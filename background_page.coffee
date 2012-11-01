# TODO: fail fast if the dom is fully loaded, yet the selector can't be found
# TODO: allow more than just freeflight.html

@goldDiggerCommands = new GoldDiggerCommands()
@goldDigger = new ChromeGoldDigger()

chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) ->
  if changeInfo.status == "complete" && /freeflight\.html/i.test(tab.url)
    chrome.tabs.executeScript tabId, {file: "proxy.js"}

chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
  # handle a no-op way to check if the plugin is active
  if request.command == "ping"
    sendResponse "pong"
  
  # create a tab
  else if request.command == "createScraper"
    goldDigger.createScraper request.args.url, (result) ->
      sendResponse result
    return true
  
  # try to execute all other commands
  else
    goldDiggerCommands.run request.args.pageId, request.command, request.args, (result) ->
      sendResponse if result == undefined || result == null then {} else result
    return true
  
  return false
