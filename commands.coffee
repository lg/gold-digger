# TODO: do something reasonable when a command doesnt exist or some sort of
# permission failed

@GoldDiggerCommands = class GoldDiggerCommands
  run: (tabId, command, args, resultCb) ->
    # validate the command is known
    methods = (k for k, v of this when typeof v is 'function')
    if command not in methods
      resultCb(null)
      return

    console.log "running command #{command}"
    safeCode = GoldDiggerCommands::[command](args)
    goldDigger.exec tabId, safeCode, (result) ->
      resultCb(result)
    
  # doesSelectorExist: selector
  doesSelectorExist: (args) ->
    selector = args.selector.replace "'", "\'"
    "document.querySelector('#{selector}') != null"
  
  # setChecked: selector,trueFalse
  setChecked: (args) ->
    selector = args.selector.replace "'", "\'"
    trueFalse = !!args["trueFalse"]
    "document.querySelector('#{selector}').checked = #{trueFalse}"

  # setValue: selector,value
  setValue: (args) ->
    selector = args.selector.replace "'", "\'"
    value = args.value.replace "'", "\'"
    "document.querySelector('#{selector}').value = '#{value}'"

  # click: selector
  click: (args) ->
    selector = args.selector.replace "'", "\'"
    "document.querySelector('#{selector}').click()"

  # getDOM: selector -- note, passed as HTML string, needs DOM creation
  getDOM: (args) ->
    selector = args.selector.replace "'", "\'"
    "document.querySelector('#{selector}').innerHTML"

