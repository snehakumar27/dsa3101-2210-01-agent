;;;;;;; Declare/Define variables and breeds ;;;;;;;
breed[cars car]
breed[persons person]
breed[crossings crossing]
breed[traffic_lights traffic_light]  ;for traffic signals

globals [
  speedLimit
  ;  redLight    ;for traffic signal
  ;  greenLight  ;for traffic signal
  ;selected-car  ;select car
  ;selected-pedestrian    ;select pedestrian
  lanes
]


patches-own [
  meaning
  will-cross?   ;may not be needed
  used
  traffic
  limit
]

persons-own [
  speed
  walk-time
  waiting?
]

;lights-own

cars-own [
  speed
  maxSpeed
  patience
  targetLane     ;:the desired lane of the car
  politeness     ;;how politeness cars are, that means how often they will stop and let people cross the road
  will-stop?     ;;whether the car will stop and let pedestrian(s) to cross the road

]

traffic_lights-own [
  redLight?
  greenLight?
  cars-light?
]


;;;;;;; Setup the Simulation ;;;;;;;
to setup
  clear-all
  set speedLimit speed-limit
  draw-roads
  draw-sidewalk
  draw-crossing
  make-cars
  make-people
  make-lights
  reset-ticks
  tick
end


to draw-roads
  ask patches [
    ;the road is surrounded by green grass of varying shades
    set pcolor 63 + random-float 0.5
  ]
  ;roads based on number of lanes
  set lanes n-values number-of-lanes [ n -> number-of-lanes - (n * 2) - 1 ]

  ; lanes on right side of the middle/divider
  ask patches with [ (0 <= pxcor) and  (pxcor <= number-of-lanes) ] [
    set pcolor grey - 2.5 + random-float 0.25
    set meaning "road-down"
  ]

  ; lanes on left side of the middle/divider
  ask patches with [ (0 >= pxcor) and  (abs pxcor <= number-of-lanes) ] [
    set pcolor grey - 2.5 + random-float 0.25
    set meaning "road-up"
  ]

  ; middle "lane" is the divider for 2-ways
  ask patches with [ abs pxcor = 0] [
    set pcolor yellow
    set meaning "divider"
  ]
end

;; hello

to draw-sidewalk
  ask patches with [(pycor = 11 or pycor = 10) and (abs pxcor > number-of-lanes) and
  (meaning !="road-up" and meaning != "road-down" and meaning != "divider")]
  [set pcolor 36 + random-float 0.3
  set meaning "sidewalk-right"]

  ask patches with [(pycor = 11 or pycor = 10) and (pxcor < number-of-lanes) and
  (meaning !="road-up" and meaning != "road-down" and meaning != "divider")]
  [set pcolor 36 + random-float 0.3
  set meaning "sidewalk-left"]

  ; may add sidewalk next to the road here, with different meanings to distinguish when creating personss
end

to draw-crossing
   ask patches with [(meaning != "sidewalk-left") and (meaning != "sidewalk-right") and (pycor = 10 or pycor = 11)][
      set pcolor white
      set meaning "crossing"
  ]

end

to make-cars
  ;create cars on left lane
  let road-patches patches with [ meaning = "road-up" or meaning = "road-down"]
  if number-of-cars > count road-patches [
    set number-of-cars count road-patches
  ]

  ask n-of (number-of-cars ) patches with [meaning = "road-up"] [
    ;check if it's a pedestrian crossing: cars 2 patches away from the crossing
    if not any? cars-on patch (pxcor + 1) pycor and
    not any? cars-here and not any? cars-on patch (pxcor - 1) pycor and
    not any? patches with [meaning = "crossing"] in-radius 2 [
     sprout-cars 1 [
        set shape "car top"
        set color car-color
        set size 1.2
        set will-stop? "maybe"
        set politeness basic-politeness + random (101 - basic-politeness)
        if random 100 > basic-politeness [set politeness random 21]
        ;move-to one-of free road-patches ; no need the above check should already take into account for this?
        set targetLane pxcor + random 2                ;starting lane is the targetLane
        set patience random max-patience     ;max-patience in beginning
        set heading 0
        ;randomly set car speed
        set speed 0.5
        let s random-float 0.2
        if s < 7 [set maxSpeed speed-limit - 0.02 + random-float 0.05]
        if s = 7 [set maxSpeed speed-limit - 0.05 + random-float 0.03]
        if s > 7 [set maxSpeed speed-limit + random-float 0.02]
        set speed maxSpeed - random-float 0.02
      ]
    ]
  ]

  ;create cars on right lane
  ask n-of (number-of-cars ) patches with [meaning = "road-down"] [
    ;check if it's a pedestrian crossing: cars 2 patches away from the crossing
    if not any? cars-on patch (pxcor + 1) pycor and
    not any? cars-here and not any? cars-on patch (pxcor - 1) pycor and
    not any? patches with [meaning = "crossing"] in-radius 2 [
     sprout-cars 1 [
        set shape "car top"
        set color car-color
        set size 1.2
        set politeness basic-politeness + random (101 - basic-politeness)
        if random 100 > basic-politeness [set politeness random 21]
        ;move-to one-of free road-patches ; no need the above check should already take into account for this?
        set targetLane pxcor                  ;starting lane is the targetLane
        set patience random max-patience      ;max-patience in beginning
        set heading 180
        ;randomly set car speed
        set speed 0.5
        let s random-float 0.2
        if s < 7 [set maxSpeed speed-limit - 0.02 + random-float 0.05]
        if s = 7 [set maxSpeed speed-limit - 0.05 + random-float 0.03]
        if s > 7 [set maxSpeed speed-limit + random-float 0.02]
        set speed maxSpeed - random-float 0.02
      ]
    ]
  ]

end

;to-report free [ road-patches ] ; turtle procedure
;  let this-car self
;  report road-patches with [
;    if not any? cars-on patch (pxcor + 1) pycor and
;    not any? cars-here and not any? cars-on patch (pxcor - 1) pycor and
;    not any? patches with [meaning = "crossing"] in-radius 2
;  ]
;end

to-report car-color
  ; give all cars a blueish color, but still make them distinguishable
  report one-of [ blue cyan sky ] + 1.5 + random-float 1.0
end

to make-people
;  while [count persons < number-of-pedestrians] [
;    ask one-of patches with [meaning = "sidewalk-left"] [
;     sprout-persons 1 [
;       set speed 0.05
;       set heading 90
;       set size 0.8
;       set waiting? false
;       set walk-time 0.05 + random (0.08 - 0.05)
;       set shape "person"
;       set color pedestrian-color
;      ]
;    ]
;  ]
; while [count persons < number-of-pedestrians] [
;    ask one-of patches with [meaning = "sidewalk-right"] [
;     sprout-persons 1 [
;       set speed 0.05
;       set heading 270
;       set size 0.8
;       set waiting? false
;       set walk-time 0.05 + random (0.08 - 0.05)
;       set shape "person"
;       set color pedestrian-color
;      ]
;    ]
;  ]

ask n-of (number-of-pedestrians) patches with [meaning = "sidewalk-left"] [
    ;check if it's a pedestrian crossing: cars 2 patches away from the crossing
;    if not any? cars-on patch (pxcor + 1) pycor and
;    not any? cars-here and not any? cars-on patch (pxcor - 1) pycor and
;    not any? patches with [meaning = "crossing"] in-radius 2 [
     sprout-persons 1 [
        set shape one-of ["person business" "person construction" "person student" "person farmer"
        "person lumberjack" "person police" "person service" "person soldier"]
        set color pedestrian-color
        set size 0.8
        ;move-to one-of free road-patches ; no need the above check should already take into account for this?
        ;set targetLane pxcor                  ;starting lane is the targetLane
        ;set patience random max-patience      ;max-patience in beginning
        set heading 90
        ;randomly set car speed
        set walk-time 0.01 + random (0.04 - 0.01)
;        let s random 10
;        if s < 7 [set maxSpeed speed-limit - 15 + random 16]
;        if s = 7 [set maxSpeed speed-limit - 20 + random 6]
;        if s > 7 [set maxSpeed speed-limit + random 16]
;        set speed maxSpeed - random 20
      ]
    ]

ask n-of (number-of-pedestrians) patches with [meaning = "sidewalk-right"] [
    ;check if it's a pedestrian crossing: cars 2 patches away from the crossing
;    if not any? cars-on patch (pxcor + 1) pycor and
;    not any? cars-here and not any? cars-on patch (pxcor - 1) pycor and
;    not any? patches with [meaning = "crossing"] in-radius 2 [
     sprout-persons 1 [
        set shape one-of ["person business" "person construction" "person student" "person farmer"
        "person lumberjack" "person police" "person service" "person soldier"]
        set color pedestrian-color
        set size 0.8
        ;move-to one-of free road-patches ; no need the above check should already take into account for this?
        ;set targetLane pxcor                  ;starting lane is the targetLane
        ;set patience random max-patience      ;max-patience in beginning
        set heading 270
        ;randomly set car speed
        set walk-time 0.01 + random (0.04 - 0.01)
;        let s random 10
;        if s < 7 [set maxSpeed speed-limit - 15 + random 16]
;        if s = 7 [set maxSpeed speed-limit - 20 + random 6]
;        if s > 7 [set maxSpeed speed-limit + random 16]
;        set speed maxSpeed - random 20
      ]
    ]

end

to-report pedestrian-color
  ; give all cars a magentaish color, but still make them distinguishable
  report one-of [ 131 132 133 ] + 1.5 + random-float 1.0
end

; for traffic signals, but pls edit the following code has issues
to make-lights
  ask patches with [(pycor = 9) and pxcor = 1] [
    sprout-traffic_lights 1 [
      set color green
      set shape "cylinder"
      set size 0.9
      set greenLight? true
      set redLight? false
      set cars-light? true
    ]
  ]

  ask patches with [(pycor = 9) and pxcor = -1] [
    sprout-traffic_lights 1 [
      set color green
      set shape "cylinder"
      set size 0.9
      set greenLight? true
      set redLight? false
      set cars-light? true
    ]
  ]

  ask patches with [(pycor = 12) and pxcor = -1] [
    sprout-traffic_lights 1 [
      set color green
      set shape "cylinder"
      set size 0.9
      set greenLight? true
      set redLight? false
      set cars-light? true
    ]
  ]

  ask patches with [(pycor = 12) and pxcor = 1] [
    sprout-traffic_lights 1 [
      set color green
      set shape "cylinder"
      set size 0.9
      set greenLight? true
      set redLight? false
      set cars-light? true
    ]
  ]

   ask patches with [(pycor = 12) and pxcor = number-of-lanes + 1] [
    sprout-traffic_lights 1 [
      set color red
      set shape "cylinder"
      set size 0.9
      set greenLight? false
      set redLight? true
      set cars-light? false
    ]
  ]

     ask patches with [(pycor = 9) and pxcor = number-of-lanes + 1 ]  [
    sprout-traffic_lights 1 [
      set color red
      set shape "cylinder"
      set size 0.9
      set greenLight? false
      set redLight? true
      set cars-light? false
    ]
  ]

     ask patches with [(pycor = 12) and pxcor = 0 - number-of-lanes - 1] [
    sprout-traffic_lights 1 [
      set color red
      set shape "cylinder"
      set size 0.9
      set greenLight? false
      set redLight? true
      set cars-light? false
    ]
  ]

    ask patches with [(pycor = 9) and pxcor = 0 - number-of-lanes - 1] [
    sprout-traffic_lights 1 [
      set color red
      set shape "cylinder"
      set size 0.9
      set greenLight? false
      set redLight? true
      set cars-light? false
    ]
  ]
end



;;;;;;; Run the Simulation ;;;;;;;

to go
  ask cars [move-cars]
  ask cars with [ patience <= 0 ] [ choose-new-lane ]
  ask cars with [ xcor != targetLane ] [ move-to-targetLane ]
  ask persons [move-pedestrians]
  ask traffic_lights with [cars-light?] [set-car-signals]
  ask traffic_lights with [not cars-light?] [set-pedestrian-signals]
;  ask cars [set-car-speed]
  tick
end

to move-cars
  speed-up-car ;
  let blocking-cars other cars in-cone (3 + speed) 180 with [ x-distance <= 1 ]
  let blocking-car min-one-of blocking-cars [ distance myself ]
  if blocking-car != nobody [
    ; match the speed of the car ahead of you and then slow
    ; down so you are driving a bit slower than that car
    set speed [ speed ] of blocking-car
    slow-down-car
  ]
  forward speed
end

to choose-new-lane ; car procedure
  ; Choose a new lane among those with the minimum
  ; distance to your current lane (i.e., your ycor).
  let other-lanes remove xcor lanes
  if not empty? other-lanes [
    let min-dist min map [ x -> abs (x - xcor) ] other-lanes
    let closest-lanes filter [ x -> abs (x - xcor) = min-dist ] other-lanes
    set targetLane one-of closest-lanes
    set patience max-patience
  ]
end

to move-to-targetLane ; car procedure
  ;set heading ifelse-value targetLane < xcor [ 180 ] [ 0 ]
  let blocking-cars other cars in-cone (1 + abs (xcor - targetLane)) 180 with [ y-distance <= 3 ]
  let blocking-car min-one-of blocking-cars [ distance myself ]
  ifelse blocking-car = nobody [
    forward 0.2
    set xcor precision xcor 0.1 ; to avoid floating point errors
  ] [
    ; slow down if the car blocking us is behind, otherwise speed up
    ifelse towards blocking-car <= 180 [ slow-down-car ] [ speed-up-car ]
  ]
end

to slow-down-car ; turtle procedure
  set speed (speed - decelaration) ; deceleration
  if speed < 0 [ set speed decelaration ]
  ; every time you hit the brakes, you loose a little patience
  set patience patience - 1
end

to-report x-distance
  report distancexy [ xcor ] of myself ycor
end

to-report y-distance
  report distancexy xcor [ ycor ] of myself
end

to speed-up-car ; car procedure
  set speed (speed + acceleration)
  if speed > maxSpeed [ set speed maxSpeed ]
end

to move-pedestrians
;  if not any? cars-on patch (pxcor + 1) pycor and
;    not any? cars-here and not any? cars-on patch (pxcor - 1) pycor and
;    not any? patches with [meaning = "crossing"] in-radius 2 [
  forward walk-time
end

;to control-traffic-signals
;  if ticks mod (50 * lights-interval * greenLight + 65 * lights-interval * redLight ) = 0 [change-color traffic_lights]
;end
;
;to change-color [lights]
;  ask one-of lights [
;    ifelse color = red [
;      set greenLight greenLight + 1
;    ][set redLight redLight + 1
;    ]
;  ]
;
;  ask lights [
;    ifelse color = red [set color green][set color red]
;  ]
;end

;; have the traffic lights change color if phase equals each intersections' my-phase
;to set-signals
;  ask traffic_lights with [ cars-light? ] [
;  if  ticks mod (lights-interval) = 0 [
;      set greenLight? (not greenLight?)
;      ;set redLight? (not redLight?)
;    ifelse greenLight? [set color red] [set color green]
;  ]
;  ]

to set-car-signals
  if  ticks mod (lights-interval) = 0 [
      set greenLight? (not greenLight?)
      set redLight? (not redLight?)
    ifelse greenLight? [set color red] [set color green]
  ]
end

to set-pedestrian-signals
  if  ticks mod (lights-interval) = 0 [
      set greenLight? (not greenLight?)
      set redLight? (not redLight?)
    ifelse greenLight? [set color red] [set color green]
  ]
end

;to set-car-speed  ;; turtle procedure
;  ask traffic_lights with [ cars-light? ] [
;  if redLight?[
;    set speed 0
;  ]
;  ]
;end
@#$#@#$#@
GRAPHICS-WINDOW
222
10
798
587
-1
-1
17.21212121212121
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
14
22
82
55
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
13
63
185
96
speed-limit
speed-limit
0
2
1.3
0.1
1
NIL
HORIZONTAL

SLIDER
13
103
185
136
lights-interval
lights-interval
0
60
7.0
1
1
seconds
HORIZONTAL

SLIDER
12
141
184
174
number-of-cars
number-of-cars
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
12
180
184
213
number-of-pedestrians
number-of-pedestrians
0
26
24.0
1
1
NIL
HORIZONTAL

SLIDER
12
220
184
253
max-patience
max-patience
0
50
30.0
1
1
NIL
HORIZONTAL

SLIDER
13
259
185
292
time-to-cross
time-to-cross
0
40
12.0
1
1
seconds
HORIZONTAL

SLIDER
13
301
185
334
number-of-lanes
number-of-lanes
0
4
3.0
1
1
NIL
HORIZONTAL

BUTTON
97
22
160
55
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
13
341
185
374
acceleration
acceleration
0
0.015
0.005
0.005
1
NIL
HORIZONTAL

SLIDER
14
422
186
455
decelaration
decelaration
0
0.5
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
14
382
186
415
basic-politeness
basic-politeness
0
100
70.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

car side
false
0
Polygon -7500403 true true 19 147 11 125 16 105 63 105 99 79 155 79 180 105 243 111 266 129 253 149
Circle -16777216 true false 43 123 42
Circle -16777216 true false 194 124 42
Polygon -16777216 true false 101 87 73 108 171 108 151 87
Line -8630108 false 121 82 120 108
Polygon -1 true false 242 121 248 128 266 129 247 115
Rectangle -16777216 true false 12 131 28 143

car top
true
0
Polygon -7500403 true true 151 8 119 10 98 25 86 48 82 225 90 270 105 289 150 294 195 291 210 270 219 225 214 47 201 24 181 11
Polygon -16777216 true false 210 195 195 210 195 135 210 105
Polygon -16777216 true false 105 255 120 270 180 270 195 255 195 225 105 225
Polygon -16777216 true false 90 195 105 210 105 135 90 105
Polygon -1 true false 205 29 180 30 181 11
Line -7500403 false 210 165 195 165
Line -7500403 false 90 165 105 165
Polygon -16777216 true false 121 135 180 134 204 97 182 89 153 85 120 89 98 97
Line -16777216 false 210 90 195 30
Line -16777216 false 90 90 105 30
Polygon -1 true false 95 29 120 30 119 11

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

crossing
true
15
Line -16777216 false 150 90 150 210
Line -16777216 false 120 90 120 210
Line -16777216 false 90 90 90 210
Line -16777216 false 240 90 240 210
Line -16777216 false 270 90 270 210
Line -16777216 false 30 90 30 210
Line -16777216 false 60 90 60 210
Line -16777216 false 210 90 210 210
Line -16777216 false 180 90 180 210
Rectangle -1 true true 0 0 30 300
Rectangle -7500403 true false 120 0 150 300
Rectangle -1 true true 180 0 210 300
Rectangle -7500403 true false 240 0 270 300
Rectangle -1 true true 30 0 60 300
Rectangle -7500403 true false 90 0 120 300
Rectangle -1 true true 150 0 180 300
Rectangle -7500403 true false 270 0 300 300
Rectangle -1 true true 60 0 90 300
Rectangle -1 true true 210 0 240 300

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person construction
false
0
Rectangle -7500403 true true 123 76 176 95
Polygon -1 true false 105 90 60 195 90 210 115 162 184 163 210 210 240 195 195 90
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Circle -7500403 true true 110 5 80
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -955883 true false 180 90 195 90 195 165 195 195 150 195 150 120 180 90
Polygon -955883 true false 120 90 105 90 105 165 105 195 150 195 150 120 120 90
Rectangle -16777216 true false 135 114 150 120
Rectangle -16777216 true false 135 144 150 150
Rectangle -16777216 true false 135 174 150 180
Polygon -955883 true false 105 42 111 16 128 2 149 0 178 6 190 18 192 28 220 29 216 34 201 39 167 35
Polygon -6459832 true false 54 253 54 238 219 73 227 78
Polygon -16777216 true false 15 285 15 255 30 225 45 225 75 255 75 270 45 285

person doctor
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -13345367 true false 135 90 150 105 135 135 150 150 165 135 150 105 165 90
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 114 156 120 195 90 270 210 270 180 195 186 155 210 210 240 195 195 90 165 90 150 150 135 90
Line -16777216 false 150 148 150 270
Line -16777216 false 196 90 151 149
Line -16777216 false 104 90 149 149
Circle -1 true false 180 0 30
Line -16777216 false 180 15 120 15
Line -16777216 false 150 195 165 195
Line -16777216 false 150 240 165 240
Line -16777216 false 150 150 165 150

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person graduate
false
0
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -8630108 true false 90 19 150 37 210 19 195 4 105 4
Polygon -8630108 true false 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -1184463 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -2674135 false 195 90 150 135
Line -2674135 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -2674135 false 208 22 208 57

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

waitpoint
false
14
Rectangle -16777216 true true 15 15 285 285
Rectangle -7500403 true false 30 30 270 270

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
