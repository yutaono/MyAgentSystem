# constants
SVG = 'http://www.w3.org/2000/svg'

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

  moveCircle : (id, dx, dy) ->
    e = document.getElementById id
    o = new Object()
    o.cx = parseFloat(e.getAttribute 'cx') + dx*8
    o.cy = parseFloat(e.getAttribute 'cy') + dy*8
    e.setAttribute 'cx', o.cx
    e.setAttribute 'cy', o.cy
    return o

  deleteCircle : (id) ->
    e = document.getElementById id
    e.parentNode.removeChild(e)
    return

###########################
class Target extends Circle
###########################
  color: 'red'
  num: 0
  @life: true

  constructor: () ->
    @id = 't' + Target::num++
    @x = 200 - 200 + Math.floor (Math.random()*400 )
    @y = 200 - 200 + Math.floor (Math.random()*400 )
    @createCircle @id, @x, @y, 10, this.color
    return

  kill: ->
    if @life is false
      return
    @life = false
    @deleteCircle @id
    Target::num--
    return

###########
class Field
###########
# Field Has Many Targets
  weight: 400
  height: 400
  maxTargetNum: 12
  targets = new Array()

  constructor: ()->
    this.setTargets()
    return

  setTargets: ()->
    for i in [1..this.maxTargetNum]
      targets.push new Target()
    return

  getTargets: ()->
    return targets

  killTargetById: (id) ->
    # pid = parseInt(id.match /\d+/g, 10)
    # console.log 'pid:', pid
    for t,i in targets
      # console.log t.id, i
      if t.id is id
        # console.log 'i:', i
        targets[i].kill()
        targets.splice i, 1
        break
    return


##########################
class Agent extends Circle
##########################
  color: 'rgba(100, 100, 100, 0.5)'

  constructor: (@id, @x, @y) ->
    @createCircle @id, @x, @y, 10, this.color
    return

  move: ->
    d = @moveCircle @id, @dx, @dy
    @x = d.cx
    @y = d.cy

  setDirectionFromTargets: (targets)->
    minDistance =  9999999 # first, very large number
    @dx = 0
    @dy = 0
    for t in targets
      d = Math.sqrt( Math.pow(t.x-@x, 2) + Math.pow(t.y-@y, 2) )
      if d < 4.2
        Field.prototype.killTargetById(t.id)
        return
      if minDistance > d
        minDistance = d
        @dx = (t.x-@x)/d
        @dy = (t.y-@y)/d
    return

##########
class Army
##########
# Army Has Many Agents
  agentNum : 0
  maxAgentNum : 2
  agents = new Array()

  constructor: () ->

  createAgent: (x, y) ->
    if Army::agentNum+1 >  Army::maxAgentNum
      console.log "Agent Max Number"
      return
    id = 'a' + Army::agentNum
    Army::agentNum++
    agents.push new Agent( id, x, y )
#    console.log 'agentNum:', Army::agentNum
    return

  moveAgents: (targets) ->
    for a in agents
      a.setDirectionFromTargets(targets)
      a.move()
    return

army = new Army()


# onload event
window.onload = (event) ->
  field = new Field()

  setInterval ->
    army.moveAgents(field.getTargets())
  , 80
  return

# click to add a agent
window.addEventListener 'click', (event) ->
  army.createAgent( event.clientX, event.clientY )
  return






