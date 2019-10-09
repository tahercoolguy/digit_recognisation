FROM python:3.7-slim-stretch

RUN apt-get update && apt-get install -y git python3-dev gcc \
    && rm -rf /var/lib/apt/lists/*

# Update packages and install basics
RUN apt-get update && apt-get install -y \
	wget \
	unzip \
	git

# Install dependencies
RUN apt-get install -y build-essential libgtk2.0-dev cmake python-dev python-numpy libeigen3-dev yasm libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev default-jdk ant libvtk5-qt4-dev

# Install pip
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py && rm get-pip.py
RUN pip install --upgrade pip

# cd to /tmp and clone repos for OpenCV and extra modules
WORKDIR /tmp
RUN git clone https://github.com/Itseez/opencv.git
RUN git clone https://github.com/Itseez/opencv_contrib.git

# Create build folder
WORKDIR /tmp/opencv
RUN mkdir /tmp/opencv/build 
WORKDIR /tmp/opencv/build

# Build OpenCV
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D INSTALL_PYTHON_EXAMPLES=ON -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib/modules ..
RUN make 
RUN make install
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf
RUN ldconfig

# Install VLFeat
RUN wget http://www.vlfeat.org/download/vlfeat-0.9.20-bin.tar.gz
RUN tar zxvf vlfeat-0.9.20-bin.tar.gz
RUN rm vlfeat-0.9.20-bin.tar.gz
ENV VLFEAT_DIR=/vlfeat-0.9.20

# Move to working dir and clean up
WORKDIR /
RUN rm -rf /tmp/*
COPY requirements.txt .

RUN pip install --upgrade -r requirements.txt

COPY app app/

RUN python app/server.py

EXPOSE 5000

CMD ["python", "app/server.py", "serve"]
