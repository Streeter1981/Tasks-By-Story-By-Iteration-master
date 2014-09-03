###

Tasks by Story by Iteration App
By Richard Green

This app displays all the tasks of every story of an iteration. You can choose which iteration you want to look at
with the combobox. If there are no stories or tasks, a panel is created that tells the user what happened, as opposed
to just having empty space where the grid should be.

This app was written in coffeescript, but updates to it can be made to either the App.coffee file or the App.js file.

I hope this app helps you!

###


Ext.define('CustomApp', {
    extend: 'Rally.app.App'
    componentCls: 'app'

    launch: -> 
      iterationCombobox = Ext.create('Rally.ui.combobox.IterationComboBox',
          listeners:
              select: (combobox) -> @storiesByIteration(combobox.getRecord().get('_ref'))
              ready: (combobox) -> @storiesByIteration(combobox.getRecord().get('_ref'))
              scope: this
          storeConfig: 
              fetch: ['Name', 'Notes', '_ref', 'StartDate', 'EndDate', 'ObjectID', 'State']
      )
      @add(iterationCombobox)

    storiesByIteration: (iterationRef) ->
      storyStore = Ext.create('Rally.data.WsapiDataStore', 

        model: 'User Story'
        autoLoad: true
        fetch: ['Name', 'ScheduleState', 'PlanEstimate', '_ref']
        filters: [property: 'Iteration', operator: '=', value: iterationRef]
        listeners:
          load: (store, storyRecords) ->
            if storyRecords.length isnt 0
              @tasksByStory(storyRecords)
            else
              @createEmptyPanel('Stories')
          scope: this

      )

    tasksByStory: (storyRecords) ->
      stories = []
      taskFilters = []

      Ext.Array.each(storyRecords, (record) ->
        stories[record.data._ref] = record
        taskFilters.push(property: 'WorkProduct', operator: '=', value: record.data._ref)
      )
      taskFilter = Rally.data.QueryFilter.or(taskFilters)
      console.log(taskFilter)

      taskStore = Ext.create 'Rally.data.WsapiDataStore', 
        model: 'Task'
        autoLoad: true
        fetch: ['Name', 'State', 'Estimate', 'ToDo', 'Actuals', '_ref', 'WorkProduct']
        filters: taskFilter
        listeners: 
          load: (store, taskRecords) ->
            if taskRecords.length isnt 0
              @aggregateData(taskRecords, stories)
            else
              @createEmptyPanel('Tasks')
          scope: this


    aggregateData: (taskRecords, stories) ->
      customStoreRecords = []
      Ext.Array.each(taskRecords, (taskRecord) ->

        storyRecord = stories[taskRecord.get('WorkProduct')._ref]
        customStoreRecords.push
          'StoryName': storyRecord.get('Name')
          'ScheduleState': storyRecord.get('ScheduleState')
          'PlanEstimate': storyRecord.get('PlanEstimate')
          'StoryRef': storyRecord.get('_ref')
          'TaskName': taskRecord.get('Name')
          'State': taskRecord.get('State')
          'Estimate': taskRecord.get('Estimate')
          'ToDo': taskRecord.get('ToDo')
          'Actuals': taskRecord.get('Actuals')
          'TaskRef': taskRecord.get('_ref')
      )
      @updateGrid(customStoreRecords)

    createGrid: (myStore) ->
      if @emptyPanel? then @remove(@emptyPanel)
      
      @myGrid = Ext.create('Rally.ui.grid.Grid',

        disableSelection: true
        store: myStore
        columnCfgs:
          [
            text: 'Story Name', dataIndex: 'StoryName' , flex: 2, 
            renderer: (value, meta, record) -> '<a href="' + Rally.nav.Manager.getDetailUrl(record.get('StoryRef')) + '">' + value + '</a>'
          ,
            text: 'ScheduleState', dataIndex: 'ScheduleState', flex: 1
          ,
            text: 'Plan Estimate', dataIndex: 'PlanEstimate', flex: 1
          ,
            text: 'Task Name', dataIndex: 'TaskName', flex: 2,
            renderer: (value, meta, record) -> '<a href="' + Rally.nav.Manager.getDetailUrl(record.get('TaskRef')) + '">' + value + '</a>'
          ,
            text: 'State', dataIndex: 'State' , flex: 1
          ,
            text: 'Estimate', dataIndex: 'Estimate' , flex: 1
          , 
            text: 'ToDo', dataIndex: 'ToDo', flex: 1
          ,
            text: 'Actuals', dataIndex: 'Actuals', flex: 1
          ]  
      )
      @add(@myGrid)

    updateGrid: (customStoreRecords) ->
      myStore = Ext.create('Rally.data.custom.Store', 
        data: customStoreRecords
      )


      if @myGrid == undefined or @myGrid.isDestroyed
        if @emptyPanel? then @remove(@emptyPanel)
        @createGrid(myStore)
      else
        @myGrid.reconfigure(myStore)

    createEmptyPanel: (item) ->
      if @myGrid? then @remove(@myGrid)
      if @emptyPanel? then @remove(@emptyPanel)


      @emptyPanel = new Ext.Panel(

        title: 'No ' + item
        titleAlign: 'center'
        html: "<I>No " + item + " in This Iteration</I>"
        style: 
          'text-align': 'center'
        bodyStyle:
          'font-size': '1.0em',
          'padding': '2px'
      )

      @add(@emptyPanel)

});
