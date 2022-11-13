# DSA3101 Project - Transport Modeling with Agents
### Group 01
This repo is under the ownership of project members

Backend Team: Sneha Kumar, Matthias Koh Yong An, Raphael Teng Yao Wei and Kwan Yu Him

Frontend Team: Zhang Aijia, You Bohan, Andrew Chunhan Chou and Hu Tingxuan

Advisers: Prof Vik Gopal, Li Keyou, Pan Yuting and Urban Redevelopment Authority (URA)

## Problem Statement
Inspired by the new Tengah town as well as the up and coming Jurong Innovation District (JID), we aim to simulate traffic flow in the new town to aid urban planners such as URA in their planning process. Through the usage of Netlogo we aim to simulate potential traffic flow and predict and prevent potential traffic build up when the new town becomes fully functional. Understanding that town planners would like to experiment and develop their most optimal plan, we have identified key parameters, such as number of lanes, traffic lights, and types of junctions, that will be added to the end user dashboard.

For the purpose of this project, we have decided to focus on a particular segment of the Tengah town which incorporates the Plantation and Garden district as well as the main road, Tengah Boulevard, leading from PIE. We have chosen this region as this new district runs parallel to Jurong West Avenue 1 which is a popular road that receives a lot of traffic flow, hence when JID is built, we could potentially see the same traffic flow in the roads of the new district. Thus, we hope that with these simulations, we could identify and assist URA to build better road features that could help reduce traffic build up and provide a smooth traffic flow for road users.

------------------------------------
## GitHub Large File Storage 

If you face issues with pulling the changes or cloning the repository, install the git LFS extension
`brew install git-lfs`

The git LFS extension has been used in this repository to keep track of the csv files containing the simulation model's outputs. 

------------------------------------
## Instructions for running the dashboard (frontend) using Docker

1. Navigate to /Frontend/Dashboard_template
2. `docker build -t dashboard .`
3. `docker run -p 8055:8055 dashboard`
4. dashboard should be up on `http://127.0.0.1:8055/`


## Instructions for running the Netlogo simulation (backend) using Docker
1. Set your working directory to `Backend/Final_Models` 

2. Choose which simulation model you would like to run and choose one of the following commands accordingly: <br />
For running the base traffic model: <br />
`docker build --build-arg MODEL_NAME=traffic_lane_pedestrian.nlogo -t traffic_model .` <br/>
For running the bike lane: <br />
`docker build --build-arg MODEL_NAME=traffic_pedestrian_bike_lane.nlogo -t traffic_model .`

3. Pull the x11 image to run GUI applications <br />
`docker run -d --name x11-bridge -e MODE="tcp" -e XPRA_HTML="yes" -e DISPLAY=:14 -e XPRA_PASSWORD=111 -p 10000:10000 jare/x11-bridge`

4. Run the netlogo model <br />
`docker run -d --name netlogo --volumes-from x11-bridge -v ~/path/to/results/folder:/home/results traffic_model`
Replace `~/path/to/results/folder` with the path on your local computer starting from `~/`

5. View the simulation <br />
`http://localhost:10000/index.html?encoding=rgb32&password=111`

** If you would like to run both models simultaneously, name the images in steps 3 & 4 separately and map it to different port in step 3 

6. To stop the container <br />
`docker stop netlogo` <br />
`docker stop x11-bridge`

**Note: The backend model may also be viewed directly with the html file.**



