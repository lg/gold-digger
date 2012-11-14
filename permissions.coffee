# TODO: actually remember permissions

class @Permissions
  constructor: () ->
    @approved = {}
  
  getPermsIfNeeded: (hostDomain, domains) ->
    newPerms = []
    
    domainsList = ""
    for domain in domains
      if !@approved[hostDomain] || domain not in @approved[hostDomain]
        newPerms.push domain
        domainsList += "  - #{domain}\n"

    if newPerms.length > 0
      result = confirm "The website #{hostDomain} is requesting permissions to scrape the following sites:\n\n#{domainsList}\nAllow GoldDigger to give permissions for this?"
      if result
        @approved[hostDomain] = [] if not @approved[hostDomain]
        @approved[hostDomain].push newPerms...
  
  hasPerms: (hostDomain, domain, askIfNeeded = false) ->
    this.getPermsIfNeeded hostDomain, [domain] if askIfNeeded
    @approved[hostDomain] && (domain in @approved[hostDomain])
  
  anyoneHasPerms: (domain) ->
    for host, approvedDomains in @approved
      return true if domain in approvedDomains
    return false