reporter = {}
reporter.showSourceList = (sources, profile) ->
  nodes = sources.map (source) ->
    id: "source-#{source.id}"
    text: source.path
    img: 'icon-folder'
    expanded: true
    group: true
    count: source.funcs.length
    nodes: source.funcs.map (func) ->
      id: "#{source.id}-#{func.id}"
      text: "line #{func.loc.start.line}: #{func.name}"
      img: 'icon-page'
    style: 'text-overflow: ellipsis'
  $ ->
    $('#sidebar').w2sidebar
      name: 'sidebar'
      nodes: nodes
  w2ui.sidebar.on 'click',  (e) ->
    ids    = e.target.split '-'
    source = sources.filter((s) -> s.id == parseInt(ids[0]))[0]
    func   = source.funcs.filter((f) -> f.id == parseInt(ids[1]))[0]
    reporter.showSource source, profile
reporter.showSource = (source, profile) ->
  if reporter.source == source
    return
  reporter.source = source
  require ["orion/editor/edit"], (edit) ->
    editorEle  = document.getElementById('editor')
    source     = source
    code       = source.code
    editorEle.innerHTML = '';
    codeEditor = new editor.edit(
      contents: code
      parent: editorEle
      readonly: true
      fullSelection: true
      lang: 'js'
      showFoldingRuler: true
      showAnnotationRuler: true
      showLinesRuler: true
      showOverviewRuler: true
      tabSize: 2
      title: 'edit'
    )
    reporter.showProblems codeEditor, source.funcs, profile
reporter.showProblems = (codeEditor, funcs, profile) ->
  calls = profile.calls
  problems = funcs.map (f) ->
    funcCalls = calls.filter((c) -> c.func.id == f.id)
    num = funcCalls.length
    maxDuration = Math.max.apply null, funcCalls.map (c) -> c.duration
    desc        = "#{f.name}() is called #{num} times." +
      "Max duration is #{maxDuration}"
    description: desc
    line:        f.loc.start.line
    start:       1
    end:         1
    severity:    "warning"
  codeEditor.showProblems problems
