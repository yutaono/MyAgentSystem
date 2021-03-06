# constants
SVG = 'http://www.w3.org/2000/svg'
dt = 50

##########
class Line
##########
  points = new Array()
  length: 0
 
  createLine : (id, x, y, color) ->
    e = document.createElementNS SVG,'path'
    e.setAttribute 'id', id
    e.setAttribute 'd', 'M' + x + ',' + y
    e.setAttribute 'stroke', color
    e.setAttribute 'stroke-width', 2
    e.setAttribute 'fill', 'none'
    document.getElementById('field').appendChild e
    points = new Array()
    points.push @p(x,y)
    return
    
  updateLine : (id, x, y) ->
    e = document.getElementById id
    d = e.getAttribute 'd'
    e.setAttribute 'd', d + ' L' + x + ',' + y
    points.push @p(x,y)
    
    l = points.length
    @length += Math.sqrt( Math.pow(points[l-2].x - points[l-1].x, 2) + Math.pow(points[l-2].y - points[l-1].y, 2) )
    document.getElementById('distance').innerHTML = Math.floor @length

  exitLine : (id) ->
    e = document.getElementById id
    d = e.getAttribute 'd'
    e.setAttribute 'd', d + ' z'

  p: (x,y) ->
    o = new Object()
    o.x = x
    o.y = y
    return o

    
############
class Circle
############
  createCircle : (id, x, y, r, color) ->
    e = document.createElementNS SVG,'circle'
    e.setAttribute 'id', id
    e.setAttribute 'cx', x
    e.setAttribute 'cy', y
    e.setAttribute 'r', r
    e.setAttribute 'fill', color
    document.getElementById('field').appendChild e
    return

  moveCircle : (id, dx, dy, v) ->
    e = document.getElementById id

    o = new Object()
    o.cx = parseFloat(e.getAttribute 'cx') + dx*v
    o.cy = parseFloat(e.getAttribute 'cy') + dy*v
    if o.cx > Field::width
      o.cx = Field::width
    if o.cx < 0
      o.cx = 0
    if o.cy > Field::height
      o.cy = Field::height
    if o.cy < 0
      o.cy = 0
      
    e.setAttribute 'cx', o.cx
    e.setAttribute 'cy', o.cy
    return o

  changeColor : (id, color) ->
    e = document.getElementById id
    e.setAttribute 'fill', color    
    return

  deleteCircle : (id) ->
    e = document.getElementById id
    e.parentNode.removeChild(e)
    return

  deleteAllCircle : () ->
    e = document.getElementById 'field'
    while e.childNodes.length >= 1
      e.removeChild e.firstChild

###########################
class Target extends Circle
###########################
  colors: ['skyblue', 'pink']
  num: 0
  velocity: 2
  life: true

  constructor: () ->
    @id = 't' + Target::num++
    @x = 200 - 200 + Math.floor (Math.random()*400 )
    @y = 200 - 200 + Math.floor (Math.random()*400 )
    @createCircle @id, @x, @y, 10, this.colors[0]
    return

  kill: ->
    if @life is false
      return
    @life = false
    @deleteCircle @id
    Target::num--
    if Target::num is 0
      alert 'end'
      location.reload true
    return

  aimed: () ->
    @changeColor @id, this.colors[1]

  move: ->
    d = @moveCircle @id, @dx, @dy, @velocity
    @x = d.cx
    @y = d.cy

  setDirectionFromAgents: (agents)->
    minDistance = 9999999 # first, very large number
    @dx = 0
    @dy = 0
    for a, i in agents
      d = Math.sqrt( Math.pow(a.x-@x, 2) + Math.pow(a.y-@y, 2) )
      if minDistance > d
        minDistance = d
        @dx = - (a.x-@x)/d
        @dy = - (a.y-@y)/d
    return        

#########################
class Field
# Field Has Many Targets
#     
#########################
  width: 400
  height: 400
  maxTargetNum: document.getElementsByName('targetNumber')[0].value
  targets = new Array()

  constructor: ()->
    this.setTargets()
    return

  setTargets: ()->
    targets = new Array()
    Target::deleteAllCircle()
    for i in [1..@maxTargetNum]
      targets.push new Target()
    return

  getTargets: ()->
    return targets

  moveTargets: (agents) ->
    for t in targets
      t.setDirectionFromAgents(agents)
      t.move()
    return 
        
  killTargetById: (id) ->
    for t,i in targets
      if t.id is id
        targets[i].kill()
        targets.splice i, 1
        break
    return


##########################
class Agent extends Circle
##########################
  color: 'rgba(100, 100, 100, 0.5)'
  velocity: 8
  path: new Line()

  constructor: (@id, @x, @y) ->
    @createCircle @id, @x, @y, 10, @color
    @pathId = 'p'+@id.match( /\d+/g )
    @path.createLine @pathId, @x, @y, @color
    return

  move: ->
    console.log
    d = @moveCircle @id, @dx, @dy, @velocity
    @x = d.cx
    @y = d.cy
    @path.updateLine @pathId, @x, @y

  setDirectionFromTargets: (targets)->
    minDistance =  9999999 # first, very large number
    @dx = 0
    @dy = 0
    aimedTargetid = 0
    for t, i in targets
      d = Math.sqrt( Math.pow(t.x-@x, 2) + Math.pow(t.y-@y, 2) )
      if d < 5.0
        Field.prototype.killTargetById(t.id)
        return false
      if minDistance > d
        minDistance = d
        @dx = (t.x-@x)/d
        @dy = (t.y-@y)/d
        aimedTargetId = i
    targets[aimedTargetId].aimed()
    return true

######################
class Army
# Army Has Many Agents
######################
  agentNum : 0
  maxAgentNum : document.getElementsByName('agentNumber')[0].value
  agents = new Array()

  constructor: () ->

  createAgent: (x, y) ->
    if Army::agentNum+1 >  Army::maxAgentNum
      console.log "Agent Max Number"
      return
    id = 'a' + Army::agentNum
    Army::agentNum++
    agents.push new Agent( id, x, y )
    return

  moveAgents: (targets) ->
    for a in agents
      if a.setDirectionFromTargets(targets)
        a.move()
    return

  getAgents: ()->
    return agents

window.onload = (event) ->
  field = new Field()
  army = new Army()

  document.getElementById('setButton').onclick = ->
    Army::maxAgentNum = document.getElementsByName('agentNumber')[0].value
    Field::maxTargetNum = document.getElementsByName('targetNumber')[0].value
    Field::setTargets()
    return

  document.getElementById('field').onclick = (event) ->
    army.createAgent( event.clientX, event.clientY )
    return

  setInterval ->
    army.moveAgents(field.getTargets())
#    field.moveTargets(army.getAgents())
  , dt
  return



