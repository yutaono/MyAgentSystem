var Agent, Army, Circle, Field, SVG, Target,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

SVG = 'http://www.w3.org/2000/svg';

Circle = (function() {
  function Circle() {}

  Circle.prototype.createCircle = function(id, x, y, r, color) {
    var e;
    e = document.createElementNS(SVG, 'circle');
    e.setAttribute('id', id);
    e.setAttribute('cx', x);
    e.setAttribute('cy', y);
    e.setAttribute('r', r);
    e.setAttribute('fill', color);
    document.getElementById('field').appendChild(e);
  };

  Circle.prototype.moveCircle = function(id, dx, dy) {
    var e, o;
    e = document.getElementById(id);
    o = new Object();
    o.cx = parseFloat(e.getAttribute('cx')) + dx * 8;
    o.cy = parseFloat(e.getAttribute('cy')) + dy * 8;
    e.setAttribute('cx', o.cx);
    e.setAttribute('cy', o.cy);
    return o;
  };

  Circle.prototype.changeColor = function(id, color) {
    var e;
    e = document.getElementById(id);
    e.setAttribute('fill', color);
  };

  Circle.prototype.deleteCircle = function(id) {
    var e;
    e = document.getElementById(id);
    e.parentNode.removeChild(e);
  };

  Circle.prototype.deleteAllCircle = function() {
    var e, _results;
    e = document.getElementById('field');
    _results = [];
    while (e.childNodes.length >= 1) {
      _results.push(e.removeChild(e.firstChild));
    }
    return _results;
  };

  return Circle;

})();

Target = (function(_super) {
  __extends(Target, _super);

  Target.prototype.colors = ['skyblue', 'pink'];

  Target.prototype.num = 0;

  Target.life = true;

  function Target() {
    this.id = 't' + Target.prototype.num++;
    this.x = 200 - 200 + Math.floor(Math.random() * 400);
    this.y = 200 - 200 + Math.floor(Math.random() * 400);
    this.createCircle(this.id, this.x, this.y, 10, this.colors[0]);
    return;
  }

  Target.prototype.kill = function() {
    if (this.life === false) {
      return;
    }
    this.life = false;
    this.deleteCircle(this.id);
    Target.prototype.num--;
    if (Target.prototype.num === 0) {
      alert('end');
      location.reload(true);
    }
  };

  Target.prototype.aimed = function() {
    return this.changeColor(this.id, this.colors[1]);
  };

  return Target;

})(Circle);

Field = (function() {
  var targets;

  Field.prototype.weight = 400;

  Field.prototype.height = 400;

  Field.prototype.maxTargetNum = document.getElementsByName('targetNumber')[0].value;

  targets = new Array();

  function Field() {
    this.setTargets();
    return;
  }

  Field.prototype.setTargets = function() {
    var i, _i, _ref;
    targets = new Array();
    Target.prototype.deleteAllCircle();
    for (i = _i = 1, _ref = this.maxTargetNum; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      targets.push(new Target());
    }
  };

  Field.prototype.getTargets = function() {
    return targets;
  };

  Field.prototype.killTargetById = function(id) {
    var i, t, _i, _len;
    for (i = _i = 0, _len = targets.length; _i < _len; i = ++_i) {
      t = targets[i];
      if (t.id === id) {
        targets[i].kill();
        targets.splice(i, 1);
        break;
      }
    }
  };

  return Field;

})();

Agent = (function(_super) {
  __extends(Agent, _super);

  Agent.prototype.color = 'rgba(100, 100, 100, 0.5)';

  function Agent(id, x, y) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.createCircle(this.id, this.x, this.y, 10, this.color);
    return;
  }

  Agent.prototype.move = function() {
    var d;
    d = this.moveCircle(this.id, this.dx, this.dy);
    this.x = d.cx;
    return this.y = d.cy;
  };

  Agent.prototype.setDirectionFromTargets = function(targets) {
    var aimedTargetId, aimedTargetid, d, i, minDistance, t, _i, _len;
    minDistance = 9999999;
    this.dx = 0;
    this.dy = 0;
    aimedTargetid = 0;
    for (i = _i = 0, _len = targets.length; _i < _len; i = ++_i) {
      t = targets[i];
      d = Math.sqrt(Math.pow(t.x - this.x, 2) + Math.pow(t.y - this.y, 2));
      if (d < 4.2) {
        Field.prototype.killTargetById(t.id);
        return;
      }
      if (minDistance > d) {
        minDistance = d;
        this.dx = (t.x - this.x) / d;
        this.dy = (t.y - this.y) / d;
        aimedTargetId = i;
      }
    }
    targets[aimedTargetId].aimed();
  };

  return Agent;

})(Circle);

Army = (function() {
  var agents;

  Army.prototype.agentNum = 0;

  Army.prototype.maxAgentNum = document.getElementsByName('agentNumber')[0].value;

  agents = new Array();

  function Army() {}

  Army.prototype.createAgent = function(x, y) {
    var id;
    if (Army.prototype.agentNum + 1 > Army.prototype.maxAgentNum) {
      console.log("Agent Max Number");
      return;
    }
    id = 'a' + Army.prototype.agentNum;
    Army.prototype.agentNum++;
    agents.push(new Agent(id, x, y));
  };

  Army.prototype.moveAgents = function(targets) {
    var a, _i, _len;
    for (_i = 0, _len = agents.length; _i < _len; _i++) {
      a = agents[_i];
      a.setDirectionFromTargets(targets);
      a.move();
    }
  };

  return Army;

})();

window.onload = function(event) {
  var army, field;
  field = new Field();
  army = new Army();
  document.getElementById('setButton').onclick = function() {
    Army.prototype.maxAgentNum = document.getElementsByName('agentNumber')[0].value;
    Field.prototype.maxTargetNum = document.getElementsByName('targetNumber')[0].value;
    Field.prototype.setTargets();
  };
  document.getElementById('field').onclick = function(event) {
    army.createAgent(event.clientX, event.clientY);
  };
  setInterval(function() {
    return army.moveAgents(field.getTargets());
  }, 40);
};

//# sourceMappingURL=main.js.map
