# TODO: See if its possible to capture errors on chrome.tabs.executeScript
#       ex. Error during tabs.executeScript: The tab was closed. 
# TODO: fix timeout to actually work

@ChromeGoldDigger = class ChromeGoldDigger
  SCRIPT_EXECUTION_TIMEOUT = 3000
  
  constructor: () ->
    @incognitoWindow = null
    
  createScraper: (url, identifierCb) ->
    if @incognitoWindow == null
      chrome.windows.getCurrent null, (currentWindow) =>
        chrome.windows.create {url: url, focused: false, incognito: true}, (window) =>
          if !window
            identifierCb null
          else
            @incognitoWindow = window.id

            # bring back to focus
            chrome.windows.update currentWindow.id, {focused: true}, =>
              identifierCb window.tabs[0].id
    else
      chrome.windows.get @incognitoWindow, (checkWindow) =>
        if !checkWindow?
          @incognitoWindow = null
          return this.createScraper url, identifierCb
        else
          chrome.tabs.create {url: url, windowId: @incognitoWindow}, (tab) =>
            identifierCb tab.id      

  exec: (identifier, code, resultCb) ->
    identifier = parseInt(identifier)
    result = null
    receivedResult = false
    skipResponse = false
    requestId = Math.floor(Math.random() * 10000000000)
    responseCb = (response, sender, sendResponse) ->
      if response['requestId'] == requestId.toString()
        result = response['result']
        receivedResult = true
    chrome.extension.onRequest.addListener responseCb

    # timeout = setTimeout ->
    #   skipResponse = true
    #   chrome.extension.onRequest.removeListener responseCb
    #   resultCb {goldDiggerError: "Timeout while executing command on the requested page."}
    # , SCRIPT_EXECUTION_TIMEOUT

    chrome.tabs.executeScript identifier, {code: "result = #{code}; chrome.extension.sendRequest({requestId: '#{requestId}', result: result});"}, ->
      #if !skipResponse
      chrome.extension.onRequest.removeListener responseCb
      #  clearTimeout timeout
      resultCb if receivedResult then result else {goldDiggerError: "Failed to receive a response from the requested page."}
