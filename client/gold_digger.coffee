# TODO: only accept messages from self both here and in the content script
# TODO: double check that removeeventlistener actually works

@GoldDigger = class GoldDigger
  PLUGIN_CHECK_TIMEOUT = 1000

  @sendCommand: (command, args, responseCb, errorCb) ->
    console.log("sending: #{command}")
    requestId = Math.floor(Math.random() * 10000000000)
    messageHandler = (event) ->
      if event.data.goldDiggerResponse && event.data.goldDiggerRequestId == requestId
        window.removeEventListener 'message', messageHandler
        if event.data.goldDiggerResponse.goldDiggerError
          errorCb event.data.goldDiggerResponse.goldDiggerError
        else  
          responseCb event.data.goldDiggerResponse
    window.addEventListener 'message', messageHandler
    window.postMessage {goldDiggerRequest: {command: command, args: args}, goldDiggerRequestId: requestId}, "*"

  @testPlugin: (resultCb) ->
    timeout = setTimeout ->
      resultCb false
    , PLUGIN_CHECK_TIMEOUT
    GoldDigger.sendCommand "ping", {}, (result) ->
      clearTimeout timeout
      resultCb if result == "pong" then true else false

  @createScraper: (url, errorCb, scraperCb) ->
    GoldDigger.sendCommand "createScraper", {url: url}, (pageId) ->
      scraperCb(new GoldDiggerScraper(pageId, errorCb))

@GoldDiggerScraper = class GoldDiggerScraper
  WAIT_TIMEOUT = 3000
  WAIT_CHECK_INTERVAL = 500
  MAX_WAIT_CHECKS = 5
  
  constructor: (@goldDiggerPageId, @failedCb) ->

  sendCommand: (command, args, resultCb) ->
    args.pageId = @goldDiggerPageId
    GoldDigger.sendCommand command, args, resultCb, @failedCb

  waitFor: (selector, successCb) ->
    this.waitForAny [selector], successCb

  waitForAny: (selectors, successCb, originalSelectors=null, triesLeft=MAX_WAIT_CHECKS) ->
    originalSelectors = selectors.slice() if originalSelectors == null
    selector = selectors.shift()
    this.doesSelectorExist selector, (success) =>
      if success
        successCb(selector)
      else
        if selectors.length == 0
          if --triesLeft <= 0
            throw "-- No elements matched any of: #{originalSelectors.join(', ')}"
          setTimeout =>
            this.waitForAny originalSelectors.slice(), successCb, originalSelectors, triesLeft
          , WAIT_CHECK_INTERVAL
        else
          this.waitForAny selectors, successCb, originalSelectors, triesLeft

  doesSelectorExist: (selector, resultCb) ->
    this.sendCommand "doesSelectorExist", {selector: selector}, resultCb

  setChecked: (selector, trueFalse, doneCb) ->
    this.sendCommand "setChecked", {selector: selector, trueFalse: trueFalse}, doneCb

  setValue: (selector, value, doneCb) ->
    this.sendCommand "setValue", {selector: selector, value: value}, doneCb

  click: (selector, doneCb) ->
    this.sendCommand "click", {selector: selector}, doneCb

  getDOM: (selector, resultCb) ->
    this.sendCommand "getDOM", {selector: selector}, (elementHTML) ->
      doc = document.implementation.createHTMLDocument ""
      docElem = doc.documentElement
      docElem.innerHTML = elementHTML
      resultCb docElem
