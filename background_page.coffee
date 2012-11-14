# TODO: fail fast if the dom is fully loaded, yet the selector can't be found
# TODO: allow more than just freeflight.html
# TODO: add something to close the window too

@goldDiggerCommands = new GoldDiggerCommands()
@goldDigger = new ChromeGoldDigger()
@permissions = new Permissions()

chrome.tabs.onUpdated.addListener (tabId, changeInfo, tab) ->
  # Inject the proxy.js script into every single page loaded by Chrome.
  # See proxy.coffee for reasoning and code
  if changeInfo.status == "complete"
    chrome.tabs.executeScript tabId, {file: "proxy.js"}

chrome.extension.onMessage.addListener (request, sender, sendResponse) ->
  # handle a no-op way to check if the plugin is active
  senderDomain = sender.tab.url.split("/")[2]
  
  if request.command == "ping"
    sendResponse "pong"
  
  else if request.command == "test"
    # noop
    return true
  
  # create a tab
  else if request.command == "createScraper"
    domain = request.args.url.split("/")[2]
    if not permissions.hasPerms senderDomain, domain, true
      sendResponse {goldDiggerError: "No permissions to create scraper on #{domain}"}
      return true
    
    goldDigger.createScraper request.args.url, (result) ->
      sendResponse result
    return true
  
  # try to execute all other commands
  else
    chrome.tabs.get request.args.pageId, (tab) ->
      domain = tab.url.split("/")[2]
      if not permissions.hasPerms senderDomain, domain, true
        sendResponse {goldDiggerError: "Page redirected and no permissions to continue scraping on #{domain}"}
        return true
      goldDiggerCommands.run request.args.pageId, request.command, request.args, (result) ->
        sendResponse if result == undefined || result == null then {} else result
    return true
  
  return false
