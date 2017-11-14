angular.module('loomioApp').factory 'RecordLoader', (Records) ->
  class RecordLoader
    constructor: (opts = {}) ->
      @loadingFirst = true
      @collection = opts.collection
      @params     = opts.params or {from: 0, per: 25, order: 'id'}
      @path       = opts.path
      @numLoaded  = opts.numLoaded or 0
      @then       = opts.then or ->

    reset: ->
      @params['from'] = 0
      @numLoaded  = 0

    fetchRecords: ->
      @loading = true
      Records[_.camelCase(@collection)].fetch
        path:   @path
        params: @params
      .then (data) =>
        if data[@collection].length > 0
          @numLoaded += data[@collection].length
        else
          @exhausted = true
        data
      .then(@then)
      .finally =>
        @loadingFirst = false
        @loading = false

    loadMore: (from) ->
      if from?
        @params['from'] = from
      else
        @params['from'] += @params['per'] if @numLoaded > 0
      @loadingMore = true
      @fetchRecords().finally => @loadingMore = false

    loadPrevious: (from) ->
      if from?
        @params['from'] = from
      else
        @params['from'] -= @params['per'] if @numLoaded > 0
      @loadingPrevious = true
      @fetchRecords().finally => @loadingPrevious = false
