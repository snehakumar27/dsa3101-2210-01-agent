FROM ubuntu:latest

WORKDIR /app

RUN apt-get update

RUN apt-get install -y python3

RUN apt-get install -y python3-venv

RUN apt-get install -y python3-pip

RUN python3 -m venv /app

COPY dashtemplate.py dashtemplate.py

COPY real_data/full_data.xlsm real_data/full_data.xlsm

COPY assets/background.jpg assets/background.jpg

COPY assets/logo.jpg assets/logo.jpg

COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

CMD ["python3", "dashtemplate.py"]

# docker build -t test01 .

# docker run -v ${PWD}:/app/tmp test01
