(->
  window.animator = animator = ->
    @ <<< que: [], running: false, bezier-param: [0.75,0,0.25,1]
    return @

  animator.intorder = <[number color numstr]>
  animator.intparser = do
    number: (vs, ve) -> if !isNaN(vs) => return [+s[k], +e[k]] else return null
    numstr: (vs, ve) ->
      if typeof(vs) == \string and /\d+/.exec(vs) => return [new NumStr(vs), new NumStr(ve)] else null
    color:  (vs, ve) ->
      if !isNaN(ldColor.hsl(vs).a) => return [ldColor.hsl(vs), ldColor.hsl(ve)] else null

  animator.intptr = do
    number: (a, b, t) -> ( b - a ) * t + a
    numstr: (a, b, t) -> NumStr.interpolate a, b, t
    color:  (a, b, t) -> 
      [a,b,c] = [ldColor.hsl(a), ldColor.hsl(b), {}]
      <[h s l a]>.map (k) -> c[k] = (b[k] - a[k]) * t + a[k]
      return ldColor.web(c)

  animator.prototype = Object.create(Object.prototype) <<< do
    bezier: (t) -> return cubic.Bezier.y(cubic.Bezier.t(t, @bezier-param),@bezier-param)
    handler: (t) ->
      @running = true
      @que.map (n) ~>
        if !n.a.st => n.a.st = t
        {vs,ve,tp,st,dur} = n.a
        n.a.percent = percent = @bezier((t - st) / dur <? 1)
        for k,v of vs =>
          v = if animator.intptr[tp[k]] => that(vs[k], ve[k], percent) else ve[k]
          n.n.setAttribute k, v
      @que = @que.filter -> it.a.percent < 1
      if @que.length => requestAnimationFrame (~> @handler it)
      else @running = false

    animate: (n, ve, dur = 333) ->
      [vs, tp] = [{}, {}]
      for k, v of ve =>
        vs[k] = n.getAttribute k
        for t in animator.intorder =>
          if !ret = animator.intparser[t](vs[k], ve[k]) => continue
          tp[k] = t
          break
      a = {vs, ve, tp, dur, st: 0}
      if !@que.filter(-> it.n == n).length => @que.push {n, a}

    start: ->
      if @running => return
      @running = true
      requestAnimationFrame (~> @handler it )

  if module? => module.exports = animator
)!
