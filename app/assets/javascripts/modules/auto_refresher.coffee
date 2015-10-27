class Muvee.AutoRefresher
  constructor: (@node, shouldRefresh) ->
    @node.click() if shouldRefresh    
