from itertools import product

speed_limit = [0.2, 0.4, 0.6, 0.8, 1]
num_cars = list(range(5, 51, 5))
num_pedestrians = list(range(5, 51, 5))
patience = [0.2, 0.4, 0.6, 0.8, 1]
acceleration = [0.2, 0.4, 0.6, 0.8, 1]
deceleration = [0.2, 0.4, 0.6, 0.8, 1]
num_lanes = [1, 2, 3, 4]
light_interval = [0.5, 1, 1.5, 2]

factors = [speed_limit, num_cars, num_pedestrians, patience,\
           acceleration, deceleration, num_lanes, light_interval]

with open("perms.txt", "w") as f:
    f.write("speed_limit, num_cars, num_pedestrians, patience,\
           acceleration, deceleration, num_lanes, light_interval")
    for elem in product(*factors):
        f.write(str(elem)[1:-1].replace("'", "") + "\n")
