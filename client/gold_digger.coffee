# TODO: only accept messages from self both here and in the content script
# TODO: double check that removeeventlistener actually works

@GoldDigger = class GoldDigger
  WAIT_TIMEOUT = 3000
  WAIT_CHECK_INTERVAL = 500
  MAX_WAIT_CHECKS = 5
  PLUGIN_CHECK_TIMEOUT = 1000

  @sendCommand: (command, args, responseCallback) ->
    requestId = Math.floor(Math.random() * 10000000000)
    messageHandler = (event) ->
      if event.data.goldDiggerResponse && event.data.goldDiggerRequestId == requestId
        window.removeEventListener 'message', messageHandler
        responseCallback event.data.goldDiggerResponse
    window.addEventListener 'message', messageHandler
    window.postMessage {goldDiggerRequest: {command: command, args: args}, goldDiggerRequestId: requestId}, "*"

  @testPlugin: (resultCb) ->
    timeout = setTimeout ->
      resultCb false
    , PLUGIN_CHECK_TIMEOUT
    GoldDigger.sendCommand "ping", null, (result) ->
      clearTimeout timeout
      resultCb if result == "pong" then true else false
  
  @createScraper: (url, pageIdCb) ->
    GoldDigger.sendCommand "createScraper", {url: url}, (pageId) ->
      pageIdCb pageId

  constructor: (@goldDiggerPageId) ->

  exec: (code, resultCb) ->
    GoldDigger.sendCommand "exec", {pageId: @goldDiggerPageId, code: code}, resultCb

  doesSelectorExist: (selector, resultCb) ->
    this.exec "document.querySelector('#{selector}') != null", (result) ->
      resultCb(result)

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

  setChecked: (selector, trueFalse, doneCb) ->
    this.exec "document.querySelector('#{selector}').checked = #{trueFalse}", ->
      doneCb()
  
  setValue: (selector, value, doneCb) ->
    this.exec "document.querySelector('#{selector}').value = \"#{value}\"", ->
      doneCb()
  
  click: (selector, doneCb) ->
    this.exec "document.querySelector('#{selector}').click()", ->
      doneCb()
  
  getDOM: (selector, resultCb) ->
    this.exec "document.querySelector('#{selector}').innerHTML", (elementHTML) ->
      doc = document.implementation.createHTMLDocument ""
      docElem = doc.documentElement
      docElem.innerHTML = elementHTML
      resultCb(docElem)
