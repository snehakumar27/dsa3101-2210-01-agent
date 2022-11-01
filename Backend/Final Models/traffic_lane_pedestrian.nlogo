;;;;;;; Declare Global Variables, Turtle Breeds and Extensions ;;;;;;;
breed[cars car]
breed[persons person]
breed[crossings crossing]
breed[traffic_lights traffic_light]
breed[towns town]
breed[datas data]

globals [
  speedLimit
  lanes
  c-lanes
  car-ticks
  pedestrian-ticks
  amber-ticks
  safety-buffer-ticks
  cycle-length
  trafficCycle
  stoppedCars
  recordData
  dataLength
  changeLane
  totalTicks
]


patches-own [
  meaning
  will-cross?   ;may not be needed
  used
  traffic
  limit
]

persons-own [
  start-head
  will-turn?
  start-on-stone?
  want-change?
  speed
  walk-time
  waiting?
]


cars-own [
  speed
  maxSpeed
  patience       ;;how patient cars are, that means how often they will stop and let people cross the road
  targetLane     ;:the desired lane of the car
  will-stop?     ;;whether the car will stop and let pedestrian(s) to cross the road
  stopTime
  stopped?
]

traffic_lights-own [
  greenLight?
  amberLight?
  redLight?
  cars-light?
]

towns-own [
  shape-to-set
]

extensions [ csv ]

;;;;;;; Setup the Simulation ;;;;;;;
to setup
  clear-all
  set speedLimit speed-limit
  set stoppedCars 0
  set dataLength 0
  set changeLane 0
  set recordData (list)
  set totalTicks (car-lights-interval + pedestrian-lights-interval)
  draw-roads
  draw-sidewalk
  draw-crossing
  make-town
  make-people
  make-cars
  make-lights
  reset-ticks
  tick
end


to draw-roads
  ask patches
  [
    ;the road is surrounded by green grass of varying shades
    set pcolor 63 + random-float 0.5
    set meaning "town"
  ]
  ;roads based on number of lanes
  set lanes n-values number-of-lanes [ n -> number-of-lanes - (n * 2) - 1 ]
  set c-lanes (range (- number-of-lanes) (number-of-lanes + 1))
  ; lanes on right side of the middle/divider
  ask patches with [ (0 <= pxcor) and  (pxcor <= number-of-lanes) ]
  [
    set pcolor grey - 2.5 + random-float 0.25
    set meaning "road-down"
  ]

  ; lanes on left side of the middle/divider
  ask patches with [ (0 >= pxcor) and  (abs pxcor <= number-of-lanes) ]
  [
    set pcolor grey - 2.5 + random-float 0.25
    set meaning "road-up"
  ]

  ; middle "lane" is the divider for 2-ways
  ask patches with [ abs pxcor = 0]
  [
    set pcolor yellow
    set meaning "divider"
  ]
end

to draw-sidewalk
  ask patches with [ (pycor = 11 or pycor = 10) and (abs pxcor > number-of-lanes) and
  (meaning !="road-up" and meaning != "road-down" and meaning != "divider") ]
  [
    set pcolor 36 + random-float 0.3
    set meaning "sidewalk-right"
  ]

  ask patches with [ (pycor = 11 or pycor = 10) and (pxcor < number-of-lanes) and
  (meaning !="road-up" and meaning != "road-down" and meaning != "divider") ]
  [
    set pcolor 36 + random-float 0.3
    set meaning "sidewalk-left"
  ]

  ask patches with [ (abs pxcor = number-of-lanes + 1) or (abs pxcor = number-of-lanes + 2) ]
  [
    set pcolor 36 + random-float 0.3
    set meaning "sidewalk-roadside"
  ]

  ; may add sidewalk next to the road here, with different meanings to distinguish when creating personss
end

to draw-crossing
  ask patches with [ meaning != "sidewalk-left" and meaning != "sidewalk-right" and meaning != "sidewalk-roadside"
    and (pycor = 10 or pycor = 11) and (abs pxcor = number-of-lanes or abs pxcor = number-of-lanes - 2 or abs pxcor = number-of-lanes - 4) ]
  [
    set pcolor white
    set meaning "crossing"
  ]

  ask patches with [ meaning != "sidewalk-left" and meaning != "sidewalk-right" and meaning != "sidewalk-roadside"
    and (pycor = 10 or pycor = 11) and (abs pxcor = number-of-lanes - 1 or abs pxcor = number-of-lanes - 3) ]
  [
    set pcolor black
    set meaning "crossing"
  ]

  ask patches with [ meaning = "sidewalk-roadside" and (pycor = 10 or pycor = 11) and (abs pxcor = number-of-lanes + 1) ]
  [
    set meaning "waitpoint"
  ]

end

to make-cars
  ;create cars on left lane
  let max-road-cap (number-of-lanes * 31)
  if number-of-cars > max-road-cap
  [
    set number-of-cars max-road-cap
  ]

  ask n-of ( number-of-cars ) patches with [ meaning = "road-up" ]
  [
    ;check if it's a pedestrian crossing: cars 2 patches away from the crossing
    if not any? cars-here and not any? patches with [ meaning = "crossing" ] in-radius 2
    [
     sprout-cars 1
      [
        set shape "car top"
        set color car-color
        set size 1.05
        set patience max-patience + random (50 - max-patience)
        if random 50 > max-patience [set patience random 21]
        ;move-to one-of free road-patches ; no need the above check should already take into account for this?
        set targetLane pxcor               ;starting lane is the targetLane
        set heading 0
        ;randomly set car speed
        set speed 0.5
        let s random 14
        if s < 7 [set maxSpeed speed-limit - 0.0005 + random-float 0.003]
        if s = 7 [set maxSpeed speed-limit - 0.0005 + random-float 0.002]
        if s > 7 [set maxSpeed speed-limit + random-float 0.001]
        set speed maxSpeed - random-float 0.002
        set stopTime 0
        set stopped? false
      ]
    ]
  ]

  ;create cars on right lane
  ask n-of ( number-of-cars ) patches with [ meaning = "road-down" ]
  [
    ;check if it's a pedestrian crossing: cars 2 patches away from the crossing
    if not any? cars-here and not any? patches with [meaning = "crossing"] in-radius 2
    [
     sprout-cars 1
      [
        set shape "car top"
        set color car-color
        set size 1.05
        set patience max-patience + random (50 - max-patience)
        if random 50 > max-patience [set patience random 21]
        ;move-to one-of free road-patches ; no need the above check should already take into account for this?
        set targetLane pxcor                  ;starting lane is the targetLane
        set heading 180
        ;randomly set car speed
        set speed 0.5
        let s random 14
        if s < 7
        [
          set maxSpeed speed-limit - 0.001 + random-float 0.005
        ]
        if s = 7
        [
          set maxSpeed speed-limit - 0.0005 + random-float 0.003
        ]
        if s > 7
        [
          set maxSpeed speed-limit + random-float 0.002
        ]
        set speed maxSpeed - random-float 0.002
      ]
    ]
  ]


end

to-report car-color
  ; give all cars a blueish color, but still make them distinguishable
  report one-of [ blue cyan sky violet ] + 1.5 + random-float 1.0
end

to make-people
  let sidewalk-patches patches with [ meaning = "sidewalk-left" or meaning = "sidewalk-right" ]
  if number-of-pedestrians > count sidewalk-patches
  [
    set number-of-pedestrians count sidewalk-patches
  ]

  let max-lr-cap (2 * (max-pycor - (number-of-lanes + 2)))
  let max-side-cap 34

  let sidewalk-left-people min (list (random number-of-pedestrians) max-lr-cap)
  let rem-people-one (number-of-pedestrians - sidewalk-left-people)
  let sidewalk-right-people min (list (random rem-people-one) max-lr-cap)
  let sidewalk-roadside-people (rem-people-one - sidewalk-right-people)

ask n-of (sidewalk-left-people) patches with [ meaning = "sidewalk-left" ]
  [
     sprout-persons 1
    [
      set shape one-of ["person business" "person construction" "person student" "person farmer"
      "person lumberjack" "person police" "person service" "person soldier" "bike top"]
      set color pedestrian-color
      set size 0.8
      set start-head 90
      set heading start-head
      set walk-time 0.023 + random-float (0.004)
      set will-turn? one-of [true false]
      set start-on-stone? false
      set want-change? false
    ]
  ]

ask n-of (sidewalk-right-people) patches with [ meaning = "sidewalk-right" ]
  [
     sprout-persons 1
    [
      set shape one-of ["person business" "person construction" "person student" "person farmer"
      "person lumberjack" "person police" "person service" "person soldier" "bike top"]
      set color pedestrian-color
      set size 0.8
      set start-head 270
      set heading start-head
      set walk-time 0.023 + random-float (0.004)
      set start-on-stone? false
      set will-turn? one-of [true false]
      set want-change? false
    ]
  ]

  ask n-of (sidewalk-roadside-people) patches with [ meaning = "sidewalk-roadside" ]
  [
     sprout-persons 1
    [
      set shape one-of ["person business" "person construction" "person student" "person farmer"
        "person lumberjack" "person police" "person service" "person soldier" "bike top"]
      set color pedestrian-color
      set size 0.8
      set start-head one-of [0 180]
      set heading start-head
      set start-on-stone? false
      set walk-time 0.023 + random-float (0.004)
      set will-turn? one-of [true false]
      set want-change? false
    ]
  ]

  ask n-of (50) patches with [ meaning = "path" ]
  [
    sprout-persons 1
    [
      set shape one-of ["person business" "person construction" "person student" "person farmer"
      "person lumberjack" "person police" "person service" "person soldier" "bike top"]
      set color pedestrian-color
      set size 0.8
        ;randomly set car speed
      set walk-time 0.023 + random-float (0.004)
      set start-on-stone? true
      set start-head random (360)
      set heading start-head
      set will-turn? one-of [true false]
      set want-change? one-of [true false]
    ]
  ]

end

to-report pedestrian-color
  ; give all cars a magentaish color, but still make them distinguishable
  report one-of [ 131 132 133 ] + 1.5 + random-float 1.0
end


to make-lights
  ;car lights initial green
  ask patches with [ (pycor = 9) and pxcor = 1 ]
  [
    sprout-traffic_lights 1
    [
      set color green
      set shape "cylinder"
      set size 0.9
      set greenLight? true
      set redLight? false
      set amberLight? false
      set cars-light? true
    ]
  ]
  ask patches with [ (pycor = 9) and pxcor = -1 ]
  [
    sprout-traffic_lights 1
    [
      set color green
      set shape "cylinder"
      set size 0.9
      set greenLight? true
      set redLight? false
      set amberLight? false
      set cars-light? true
    ]
  ]
  ask patches with [ (pycor = 12) and pxcor = -1 ]
  [
    sprout-traffic_lights 1
    [
      set color green
      set shape "cylinder"
      set size 0.9
      set greenLight? true
      set redLight? false
      set amberLight? false
      set cars-light? true
    ]
  ]
  ask patches with [ (pycor = 12) and pxcor = 1 ]
  [
    sprout-traffic_lights 1
    [
      set color green
      set shape "cylinder"
      set size 0.9
      set greenLight? true
      set redLight? false
      set amberLight? false
      set cars-light? true
    ]
  ]

  ;pedestrian lights red
   ask patches with [ (pycor = 12) and pxcor = number-of-lanes + 1 ]
  [
    sprout-traffic_lights 1
    [
      set color red
      set shape "cylinder"
      set size 0.9
      set greenLight? false
      set redLight? true
      set amberLight? false
      set cars-light? false
    ]
  ]
  ask patches with [ (pycor = 9) and pxcor = number-of-lanes + 1 ]
  [
    sprout-traffic_lights 1
    [
      set color red
      set shape "cylinder"
      set size 0.9
      set greenLight? false
      set redLight? true
      set amberLight? false
      set cars-light? false
    ]
  ]
  ask patches with [ (pycor = 12) and pxcor = 0 - number-of-lanes - 1 ]
  [
    sprout-traffic_lights 1
    [
      set color red
      set shape "cylinder"
      set size 0.9
      set greenLight? false
      set redLight? true
      set amberLight? false
      set cars-light? false
    ]
  ]
  ask patches with [ (pycor = 9) and pxcor = 0 - number-of-lanes - 1 ]
  [
    sprout-traffic_lights 1
    [
      set color red
      set shape "cylinder"
      set size 0.9
      set greenLight? false
      set redLight? true
      set amberLight? false
      set cars-light? false
    ]
  ]
  set car-ticks car-lights-interval * 60 * 20
  set pedestrian-ticks number-of-lanes * 2 * 7 * 20
  set amber-ticks 3 * 20
  set safety-buffer-ticks 3 * 20
  set trafficCycle 0
  set cycle-length (car-ticks + amber-ticks + pedestrian-ticks + safety-buffer-ticks + safety-buffer-ticks)
end


to make-town
  ;; set paths on vertical paths
  ask patches with [ ((number-of-lanes + 2 < abs pxcor) and (abs pxcor < 9)) or ((8 <= pycor) and (pycor <= 13))
    and meaning = "town" ]
  [
    set pcolor brown - 1 - random-float (0.5)
    set meaning "path"
    sprout 1
    [
    set shape "tile stones"
    set color 36
    stamp
    die
    ]
  ]
 ;put plants
 ask n-of (40) patches with [ meaning = "path" ]
  [
    if not any? turtles in-radius 2
    [
      sprout-towns 1
      [
        set shape-to-set one-of ["flower" "plant"]
        if shape-to-set = "flower"
        [
          set shape one-of ["flower" "flower budding"]
          set size 1.2
          set color one-of [red yellow pink]
        ]
        if shape-to-set = "plant"
        [
          set shape one-of ["plant" "plant medium"]
          set size 2
          set color green + 6 + random-float (0.5)
        ]
      ]
    ]
  ]

  ;; bottom patches
  ask patches with [ (meaning = "town" and abs pxcor = 13 and pycor = 5) ]
  [
    sprout-towns 1
    [
      set shape one-of ["house ranch" "house colonial" "house two story"]
      set color 26 + random-float(2)
      set size 7
      set heading 0
    ]
  ]

  ask patches with [ (meaning = "town" and (abs pxcor = 10 or abs pxcor = 13 or abs pxcor = 16) and pycor = 0) ]
  [
    sprout-towns 1
    [
      set shape one-of ["tree" "tree pine"]
      set color 62 + random-float (1)
      set size 3.6
    ]
  ]

  ask patches with [ (meaning = "town" and (pxcor = -10)) and pycor mod 4 = 0 and pycor != 4 and pycor != 0 ]
  [
    sprout-towns 1
    [
      set shape one-of ["tree" "tree pine"]
      set color 62 + random-float (1.3)
      set size 3
    ]
  ]

  ask patches with [ (meaning = "town" and (pxcor = -14) and pycor <= -4 and pycor mod -4 = 0) ]
  [
    sprout-towns 1
    [
      set shape one-of ["house bungalow" "house efficiency"]
      set color 16 + random-float(2)
      set heading 270
      set size 5
    ]
  ]

 ask patches with [ meaning = "town" and (pxcor = 13) and pycor = -7 ]
  [
    sprout-towns 1
    [
      set shape "building institution"
      set color 86 + random-float(2)
      set heading 90
      set size 7
    ]
  ]

 ask patches with [ (meaning = "town" and (pxcor = 10 or pxcor = 12 or pxcor = 14 or pxcor = 16) and pycor = -12) ]
  [
    sprout-towns 1
    [
      set shape one-of ["plant" "plant medium"]
      set color 55 + random-float (1)
      set size 2
    ]
  ]

 ask patches with [ meaning = "town" and (pxcor = 11 or pxcor = 15) and pycor = -14 ]
  [
    sprout-towns 1
    [
      set shape one-of ["house bungalow" "house efficiency"]
      set color 137 + random-float(2)
      set heading 0
      set size 4.5
    ]
  ]

   ask patches with [ meaning = "town" and (pxcor = 10 or pxcor = 12 or pxcor = 14 or pxcor = 16) and pycor = 15 ]
  [
      sprout-towns 1
    [
        set shape-to-set one-of ["flower" "plant"]
        if shape-to-set = "flower"
      [
          set shape one-of ["flower" "flower budding"]
          set size 1.5
          set color one-of [red yellow pink]
      ]
        if shape-to-set = "plant"
      [
          set shape one-of ["plant" "plant medium"]
          set size 2
          set color 55 + random-float (2)
      ]
    ]
  ]

end

;;;;;;; Run the Simulation ;;;;;;;

to go
  ask cars [move-cars]
  if number-of-lanes > 1
  [
    ask cars with [ patience <= 0 and speed > 0.01 ] [ choose-new-lane ]
    ask cars with [ xcor != targetLane ] [ move-to-targetLane ]
  ]
  ask persons [move-pedestrians]
  ;ask traffic_lights [check-switch-lights]
  ask traffic_lights with [ cars-light? ] [ check-car-switch-lights ]
  ask traffic_lights with [ not cars-light? ] [ check-pedestrian-switch-lights ]
  set stoppedCars (count cars with [ speed = 0 ])
  tick
end

to move-cars

  let blocking-cars other cars in-cone (1 + ((speed / decelaration) * speed)) 120 with [ y-distance <= 2  ]
  let blocking-car min-one-of blocking-cars [ distance myself ]
  if blocking-car != nobody
  [
    ; match the speed of the car ahead of you and then slow
    ; down so you are driving a bit slower than that car
    slow-down-car
    set speed [ speed ] of blocking-car
  ]

  let cstop? false
  ask traffic_lights with [cars-light?]
  [
    ifelse redLight? [set cstop? true] [set cstop? false]
  ]

  ifelse [meaning] of patch-here = "crossing"
  [

    ifelse any? persons-on patch-ahead 1;in-cone 1 90
    [
      set speed 0
      set stopTime stopTime + 1
    ]
    [
      set blocking-cars other cars in-cone (1 + ((speed / decelaration) * speed)) 120 with [ y-distance <= 2  ]
      set blocking-car min-one-of blocking-cars [ distance myself ]
      ifelse blocking-car != nobody
      [
        slow-down-car
        set speed [ speed ] of blocking-car
      ]
      [
        speed-up-car
        fd speed
      ]
    ]
  ]
  [
    ifelse [meaning] of patch-ahead 1 = "crossing"
    [
      ifelse cstop?
      [
        set speed 0
        set stopTime stopTime + 1
      ]
      [
        ifelse speed = 0
        [
          ifelse any? persons-on patch-ahead 1
          [
            set speed 0
            set stopTime stopTime + 1
          ]
          [
             set blocking-cars other cars in-cone (1 + ((speed / decelaration) * speed)) 120 with [ y-distance <= 2  ]
             set blocking-car min-one-of blocking-cars [ distance myself ]
             ifelse blocking-car != nobody
            [
             slow-down-car
             set speed [ speed ] of blocking-car
            ]
            [
              speed-up-car
              fd speed
            ]
          ]
        ]
        [
          set blocking-cars other cars in-cone (1 + ((speed / decelaration) * speed)) 120 with [ y-distance <= 2  ]
          set blocking-car min-one-of blocking-cars [ distance myself ]
          ifelse blocking-car != nobody
          [
            slow-down-car
            set speed [ speed ] of blocking-car
          ]
          [
            speed-up-car
            fd speed
          ]
        ]
      ]
    ]
    [
      set blocking-cars other cars in-cone (1 + ((speed / decelaration) * speed)) 120 with [ y-distance <= 2  ]
      set blocking-car min-one-of blocking-cars [ distance myself ]
      ifelse blocking-car != nobody
      [
        slow-down-car
        set speed [ speed ] of blocking-car
      ]
      [
        speed-up-car
        fd speed
      ]
    ]
  ]

end


to choose-new-lane ; car procedure
  ; Choose a new lane among those with the minimum
  ; distance to your current lane (i.e., your xcor).
  let other-lanes remove pxcor c-lanes
  ;let other-lane lanes
  set other-lanes remove 0 other-lanes
  ;set other-lanes remove 0.5 other-lanes

  if not empty? other-lanes
  [
    let min-dist min map [ x -> abs (x - pxcor) ] other-lanes
    let closest-lanes filter [ x -> abs (x - pxcor) = min-dist ] other-lanes
    set targetLane one-of closest-lanes
    set patience max-patience
  ]
end

to move-to-targetLane ; car procedure
  ; NEED TO look how to restrict overtake in road up and road down only

  if (meaning = "road-up")
  [
    if (meaning != "crossing" and speed != 0)
    [
      set heading ifelse-value targetLane < xcor [ 270 ] [ 90 ]
      let blocking-cars other cars in-cone (abs(xcor - targetLane)) 150 with [ y-distance <= 1 and x-distance <= 1 ]
      let blocking-car min-one-of blocking-cars [ distance myself ]
      ifelse blocking-car = nobody
      [
        forward 0.1
        set xcor precision xcor 1 ; to avoid floating point errors
        set heading 0
        set changeLane changeLane + 1
      ]
      [
        ;slow down if the car blocking us is behind, otherwise speed up
        ifelse towards blocking-car <= 90 [ slow-down-car ] [ speed-up-car ]
        set heading 0
      ]
    ]
  ]

  if (meaning = "road-down")
  [
    if (meaning != "crossing" and speed != 0)
    [
      set heading ifelse-value targetLane < xcor [ 270 ] [ 90 ]
      let blocking-cars other cars in-cone (abs(xcor - targetLane)) 120 with [ y-distance <= 1 and x-distance <= 1 ]
      let blocking-car min-one-of blocking-cars [ distance myself ]
      ifelse blocking-car = nobody
      [
        forward 0.1
        set xcor precision xcor 1 ; to avoid floating point errors
        set heading 180
      ]
      [
        ; slow down if the car blocking us is behind, otherwise speed up
        ifelse towards blocking-car <= 90 [ slow-down-car ] [ speed-up-car ]
        set heading 180
      ]
    ]
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
  set speed (speed + acceleration + random-float 0.005)
  if speed > maxSpeed [ set speed (maxSpeed - 0.001) ]
end

to move-pedestrians
  change-heading

  let stop? true
  ask traffic_lights with [not cars-light?]
  [
    ifelse greenLight? [set stop? true] [set stop? false]
  ]

  ifelse [meaning] of patch-ahead 1 = "crossing"
  [
    ifelse (stop?)
    [
      set walk-time 0.01 + random-float (0.06 - 0.01)
      forward walk-time
    ]
    [
      ifelse [meaning] of patch-here = "crossing"
      [
        forward walk-time
      ]
      [set walk-time 0]
    ]
  ]
  [forward walk-time]
  ;change-heading

  if start-on-stone? [get-to-sidewalk]
end

to get-to-sidewalk
  if [meaning] of patch-ahead 1 = "town"
  [
    set heading (random 360)
  ]
  if [meaning] of patch-here = "sidewalk-roadside"
  [
    ifelse want-change?
    [
      if [meaning] of patch-ahead 1 = one-of ["road-up" "road-down"]
      [
        set heading one-of [0 180]
        set start-on-stone? false
        set want-change? false
      ]
    ]
    [set heading (random 360)]
  ]

  if [meaning] of patch-here = "sidewalk-left"
  [
    ifelse want-change?
    [
      if [meaning] of patch-ahead 1 = one-of ["road-up" "road-down"]
      [
        set heading one-of [90 270]
        set start-on-stone? false
        set want-change? false
      ]
    ]
    [set heading (random 360)]
  ]

  if [meaning] of patch-here = "sidewalk-right"
  [
    ifelse want-change?
    [
      if [meaning] of patch-ahead 1 = one-of ["road-up" "road-down"]
      [
        set heading one-of [90 270]
        set start-on-stone? false
        set want-change? false
      ]
    ]
    [set heading (random 360)]
  ]

   if [meaning] of patch-here = "waitpoint"
  [
    ifelse want-change?
    [
      if [meaning] of patch-ahead 1 = one-of ["road-up" "road-down"]
      [
        set heading one-of [90 270]
        set start-on-stone? false
        set want-change? false
      ]
    ]
    [set heading (random 360)]
  ]
  if [meaning] of patch-here = one-of ["road-up" "road-down"] [die]
end

to change-heading
  if start-head = 0 and (will-turn?)
  [
    if ([meaning] of patch-here = "waitpoint") and ([meaning] of patch-ahead 1 != "waitpoint")
    [
      set start-head one-of [90 270]
      set heading start-head
      set will-turn? one-of [true false]
    ]
  ]

  if start-head = 180 and (will-turn?)
  [
    if ([meaning] of patch-here = "waitpoint") and ([meaning] of patch-ahead 1 != "waitpoint")
    [
      set start-head one-of [90 270]
      set heading start-head
      set will-turn? one-of [true false]
    ]
  ]

  if start-head = 90 and (will-turn?)
  [
    if [meaning] of patch-here = "waitpoint"
    [
      set start-head one-of [0 180]
      set heading start-head
      set will-turn? one-of [true false]
    ]
  ]

  if start-head = 270  and (will-turn?)
  [
    if [meaning] of patch-here = "waitpoint"
    [
      set start-head one-of [0 180]
      set heading start-head
      set will-turn? one-of [true false]
    ]
  ]

end

to check-car-switch-lights
    if ticks mod (cycle-length) = 1
  [
      set trafficCycle trafficCycle + 1
      set stoppedCars 0
      set changeLane 0
      ask cars [set stopTime 0]
  ]

    if ((ticks - (cycle-length * trafficCycle)) mod cycle-length = 0)
  [
      set color green
      set greenLight? not greenLight?
      set redLight? not redLight?
  ]

    if ((ticks - (cycle-length * trafficCycle) - car-ticks) mod cycle-length = 0)
  [
      set color 25.5
      set greenLight? not greenLight?
      set amberLight? not amberLight?
  ]

    if ((ticks - (cycle-length * trafficCycle) - car-ticks - safety-buffer-ticks) mod cycle-length = 0)
  [
      set color red
      set amberLight? not amberLight?
      set redLight? not redLight?
  ]

end

to check-pedestrian-switch-lights

  if ((ticks - (cycle-length * trafficCycle) - car-ticks - amber-ticks - safety-buffer-ticks ) mod cycle-length = 0)
  [
     set color green
     set redLight? not redLight?
     set greenLight? not greenLight?
  ]

  if ((ticks - (cycle-length * trafficCycle)  + safety-buffer-ticks) mod cycle-length = 0)
  [
    set color red
    set greenLight? not greenLight?
    set redLight? not redLight?
  ]

end

to record-current-data
  set dataLength (length recordData)
  set recordData (lput (list (mean [speed] of cars) (mean [stopTime] of cars) stoppedCars) recordData)
end

to write-to-csv
  csv:to-file "output.csv" recordData
end
@#$#@#$#@
GRAPHICS-WINDOW
278
10
854
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
0.2
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
11
413
272
446
pedestrian-lights-interval
pedestrian-lights-interval
0
45
45.0
15
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
124
62.0
1
1
NIL
HORIZONTAL

SLIDER
12
102
184
135
number-of-pedestrians
number-of-pedestrians
0
44
40.0
1
1
NIL
HORIZONTAL

SLIDER
12
179
184
212
max-patience
max-patience
0
100
25.0
1
1
NIL
HORIZONTAL

SLIDER
12
219
184
252
number-of-lanes
number-of-lanes
0
4
4.0
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
G
NIL
NIL
0

SLIDER
12
259
184
292
acceleration
acceleration
0
0.01
0.01
0.002
1
NIL
HORIZONTAL

SLIDER
12
297
184
330
decelaration
decelaration
0
0.1
0.1
0.02
1
NIL
HORIZONTAL

SLIDER
12
374
206
407
car-lights-interval
car-lights-interval
0
2
2.0
0.5
1
min
HORIZONTAL

SLIDER
12
336
192
369
buffer-time
buffer-time
0
5
5.0
1
1
seconds
HORIZONTAL

PLOT
5
598
205
748
Average Speed of Cars
Time
Avg Speed
0.0
5.0
0.0
10.0
true
false
"set-plot-y-range 0 speed-limit" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [speed] of cars"

PLOT
206
598
515
748
Average Speed of People
Time
Avg Speed
0.0
5.0
0.0
10.0
true
false
"set-plot-y-range (mean [walk-time] of persons) ((mean [walk-time] of persons) + 0.00001)" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [walk-time] of persons"

BUTTON
11
494
120
527
NIL
write-to-csv
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
453
170
486
NIL
record-current-data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
516
598
716
748
Average Stoptime of Cars
Time
Stoptime
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [stopTime] of cars"

PLOT
718
597
918
747
No. of Cars Stopped
Time
Number
0.0
5.0
0.0
10.0
true
false
"set-plot-y-range 0 number-of-cars" ""
PENS
"default" 1.0 0 -16777216 true "" "plot stoppedCars"

PLOT
919
597
1119
747
No. of Cars Changing Lanes
Time
Number
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot changeLane"

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

bike
true
1
Line -7500403 false 163 183 228 184
Circle -7500403 false false 213 184 22
Circle -7500403 false false 156 187 16
Circle -16777216 false false 28 148 95
Circle -16777216 false false 24 144 102
Circle -16777216 false false 174 144 102
Circle -16777216 false false 177 148 95
Polygon -2674135 true true 75 195 90 90 98 92 97 107 192 122 207 83 215 85 202 123 211 133 225 195 165 195 164 188 214 188 202 133 94 116 82 195
Polygon -2674135 true true 208 83 164 193 171 196 217 85
Polygon -2674135 true true 165 188 91 120 90 131 164 196
Line -7500403 false 159 173 170 219
Line -7500403 false 155 172 166 172
Line -7500403 false 166 219 177 219
Polygon -16777216 true false 187 92 198 92 208 97 217 100 231 93 231 84 216 82 201 83 184 85
Polygon -7500403 true false 71 86 98 93 101 85 74 81
Rectangle -16777216 true false 75 75 75 90
Polygon -16777216 true false 70 87 70 72 78 71 78 89
Circle -7500403 false false 153 184 22
Line -7500403 false 159 206 228 205

bike top
true
1
Polygon -2674135 true true 210 45 92 45 92 60 210 60
Polygon -13345367 true false 158 164 158 59 142 59 143 164
Polygon -2674135 true true 128 210 143 225 158 225 173 210 158 180 158 150 143 150 143 165 143 180
Rectangle -16777216 true false 75 75 75 90
Polygon -16777216 true false 70 87 70 72 78 71 78 89
Polygon -16777216 true false 173 226 128 226 128 241 173 241
Polygon -13345367 true false 144 239 144 284 159 284 159 239
Polygon -2674135 true true 207 45 207 75 222 90 222 45
Circle -955883 true false 115 103 66
Polygon -16777216 true false 119 166 119 196 179 196 179 166
Polygon -2674135 true true 93 45 93 75 78 90 78 45
Polygon -16777216 true false 232 58 233 75 202 75 172 58
Polygon -16777216 true false 68 58 67 75 98 75 128 58
Polygon -955883 true false 203 71 182 175 171 169 188 71
Polygon -955883 true false 97 71 118 175 129 169 112 71

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

building institution
true
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

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
Line -7500403 true 210 165 195 165
Line -7500403 true 90 165 105 165
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

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

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

flower budding
false
0
Polygon -7500403 true true 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Polygon -7500403 true true 189 233 219 188 249 173 279 188 234 218
Polygon -7500403 true true 180 255 150 210 105 210 75 240 135 240
Polygon -7500403 true true 180 150 180 120 165 97 135 84 128 121 147 148 165 165
Polygon -7500403 true true 170 155 131 163 175 167 196 136

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house bungalow
true
0
Rectangle -7500403 true true 210 75 225 255
Rectangle -7500403 true true 90 135 210 255
Rectangle -16777216 true false 165 195 195 255
Line -16777216 false 210 135 210 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 150 75 150 150 75
Line -16777216 false 75 150 225 150
Line -16777216 false 195 120 225 150
Polygon -16777216 false false 165 195 150 195 180 165 210 195
Rectangle -16777216 true false 135 105 165 135

house colonial
true
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

house efficiency
true
0
Rectangle -7500403 true true 180 90 195 195
Rectangle -7500403 true true 90 165 210 255
Rectangle -16777216 true false 165 195 195 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 165 75 165 150 90
Line -16777216 false 75 165 225 165

house ranch
true
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

house two story
true
0
Polygon -7500403 true true 2 180 227 180 152 150 32 150
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 75 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 90 150 135 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Rectangle -7500403 true true 15 180 75 255
Polygon -7500403 true true 60 135 285 135 240 90 105 90
Line -16777216 false 75 135 75 180
Rectangle -16777216 true false 30 195 93 240
Line -16777216 false 60 135 285 135
Line -16777216 false 255 105 285 135
Line -16777216 false 0 180 75 180
Line -7500403 true 60 195 60 240
Line -7500403 true 154 195 154 255

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

plant medium
false
0
Rectangle -7500403 true true 135 165 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 165 120 120 150 90 180 120 165 165

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

tile brick
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60

tile log
false
0
Rectangle -7500403 true true 0 0 300 300
Line -16777216 false 0 30 45 15
Line -16777216 false 45 15 120 30
Line -16777216 false 120 30 180 45
Line -16777216 false 180 45 225 45
Line -16777216 false 225 45 165 60
Line -16777216 false 165 60 120 75
Line -16777216 false 120 75 30 60
Line -16777216 false 30 60 0 60
Line -16777216 false 300 30 270 45
Line -16777216 false 270 45 255 60
Line -16777216 false 255 60 300 60
Polygon -16777216 false false 15 120 90 90 136 95 210 75 270 90 300 120 270 150 195 165 150 150 60 150 30 135
Polygon -16777216 false false 63 134 166 135 230 142 270 120 210 105 116 120 88 122
Polygon -16777216 false false 22 45 84 53 144 49 50 31
Line -16777216 false 0 180 15 180
Line -16777216 false 15 180 105 195
Line -16777216 false 105 195 180 195
Line -16777216 false 225 210 165 225
Line -16777216 false 165 225 60 225
Line -16777216 false 60 225 0 210
Line -16777216 false 300 180 264 191
Line -16777216 false 255 225 300 210
Line -16777216 false 16 196 116 211
Line -16777216 false 180 300 105 285
Line -16777216 false 135 255 240 240
Line -16777216 false 240 240 300 255
Line -16777216 false 135 255 105 285
Line -16777216 false 180 0 240 15
Line -16777216 false 240 15 300 0
Line -16777216 false 0 300 45 285
Line -16777216 false 45 285 45 270
Line -16777216 false 45 270 0 255
Polygon -16777216 false false 150 270 225 300 300 285 228 264
Line -16777216 false 223 209 255 225
Line -16777216 false 179 196 227 183
Line -16777216 false 228 183 266 192

tile stones
false
0
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

tile water
false
0
Rectangle -7500403 true true -1 0 299 300
Polygon -1 true false 105 259 180 290 212 299 168 271 103 255 32 221 1 216 35 234
Polygon -1 true false 300 161 248 127 195 107 245 141 300 167
Polygon -1 true false 0 157 45 181 79 194 45 166 0 151
Polygon -1 true false 179 42 105 12 60 0 120 30 180 45 254 77 299 93 254 63
Polygon -1 true false 99 91 50 71 0 57 51 81 165 135
Polygon -1 true false 194 224 258 254 295 261 211 221 144 199

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

tree pine
false
0
Rectangle -6459832 true false 120 225 180 300
Polygon -7500403 true true 150 240 240 270 150 135 60 270
Polygon -7500403 true true 150 75 75 210 150 195 225 210
Polygon -7500403 true true 150 7 90 157 150 142 210 157 150 7

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

truck cab top
true
0
Rectangle -7500403 true true 70 45 227 120
Polygon -7500403 true true 150 8 118 10 96 17 90 30 75 135 75 195 90 210 150 210 210 210 225 195 225 135 209 30 201 17 179 10
Polygon -16777216 true false 94 135 118 119 184 119 204 134 193 141 110 141
Line -16777216 false 130 14 168 14
Line -16777216 false 130 18 168 18
Line -16777216 false 130 11 168 11
Line -16777216 false 185 29 194 112
Line -16777216 false 115 29 106 112
Line -16777216 false 195 225 210 240
Line -16777216 false 105 225 90 240
Polygon -16777216 true false 210 195 195 195 195 150 210 143
Polygon -16777216 false false 90 143 90 195 105 195 105 150 90 143
Polygon -16777216 true false 90 195 105 195 105 150 90 143
Line -7500403 true 210 180 195 180
Line -7500403 true 90 180 105 180
Line -16777216 false 212 44 213 124
Line -16777216 false 88 44 87 124
Line -16777216 false 223 130 193 112
Rectangle -7500403 true true 225 133 244 139
Rectangle -7500403 true true 56 133 75 139
Rectangle -7500403 true true 120 210 180 240
Rectangle -7500403 true true 93 238 210 270
Rectangle -16777216 true false 200 217 224 278
Rectangle -16777216 true false 76 217 100 278
Circle -16777216 false false 135 240 30
Line -16777216 false 77 130 107 112
Rectangle -16777216 false false 107 149 192 210
Rectangle -1 true false 180 9 203 17
Rectangle -1 true false 97 9 120 17

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

van top
true
0
Polygon -7500403 true true 90 117 71 134 228 133 210 117
Polygon -7500403 true true 150 8 118 10 96 17 85 30 84 264 89 282 105 293 149 294 192 293 209 282 215 265 214 31 201 17 179 10
Polygon -16777216 true false 94 129 105 120 195 120 204 128 180 150 120 150
Polygon -16777216 true false 90 270 105 255 105 150 90 135
Polygon -16777216 true false 101 279 120 286 180 286 198 281 195 270 105 270
Polygon -16777216 true false 210 270 195 255 195 150 210 135
Polygon -1 true false 201 16 201 26 179 20 179 10
Polygon -1 true false 99 16 99 26 121 20 121 10
Line -16777216 false 130 14 168 14
Line -16777216 false 130 18 168 18
Line -16777216 false 130 11 168 11
Line -16777216 false 185 29 194 112
Line -16777216 false 115 29 106 112
Line -7500403 false 210 180 195 180
Line -7500403 false 195 225 210 240
Line -7500403 false 105 225 90 240
Line -7500403 false 90 180 105 180

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
