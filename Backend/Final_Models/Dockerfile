FROM openjdk:11-jdk

ARG MODEL_NAME

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    DISPLAY=:14

RUN mkdir /home/netlogo/ 
RUN wget https://ccl.northwestern.edu/netlogo/6.3.0/NetLogo-6.3.0-64.tgz
RUN tar xzf NetLogo-6.3.0-64.tgz -C /home/netlogo --strip-components=1 
RUN rm NetLogo-6.3.0-64.tgz 
RUN cp /home/netlogo/netlogo-headless.sh /home/netlogo/netlogo-headw.sh
RUN sed -i -e 's/org.nlogo.headless.Main/org.nlogo.app.App/g' /home/netlogo/netlogo-headw.sh
RUN apt-get update && apt-get install -y libxrender1 libxtst6 && apt-get -y install sudo

COPY $MODEL_NAME /home/src/NLModel.nlogo
RUN mv /home/src/NLModel.nlogo $MODEL_NAME
COPY $MODEL_NAME /home/src/NLModel.nlogo

CMD ["/home/netlogo/netlogo-headw.sh", "/home/src/NLModel.nlogo"]

### DOCKER COMMANDS ###

### Docker build
## Choose only one of the 2 models below

## For base traffic lane model 
#docker build --build-arg MODEL_NAME=traffic_lane_pedestrian.nlogo -t traffic_model .

## For bike lane model
#docker build --build-arg MODEL_NAME=traffic_pedestrian_bike_lane.nlogo -t traffic_model .

###  Docker run
#docker run -d --name x11-bridge -e MODE="tcp" -e XPRA_HTML="yes" -e DISPLAY=:14 -e XPRA_PASSWORD=111 -p 10000:10000 jare/x11-bridge

### Saving your experimental results
### Replace the path/to/folder in the code below with to the actual path of the results folder that is in the Backend Folder 
#docker run -d --name netlogo --volumes-from x11-bridge -v ~/path/to/folder:/home/results traffic_model

### To view model 
#http://localhost:10000/index.html?encoding=rgb32&password=111

### Stop container 
#docker stop netlogo
#docker stop x11-bridge 

### Remove container 
#docker rm netlogo
#docker rm x11-bridge

