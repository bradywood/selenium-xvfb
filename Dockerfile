#FROM ubuntu:trusty-20150630
FROM ernie_javabase:latest

MAINTAINER Brady Wood

### SET UP
# BASE wheezy-backports O/S with some helpful tools
#RUN echo "deb http://ftp.us.debian.org/debian wheezy-backports main" >> /etc/apt/sources.list
RUN yum install -y openssl-libs-1.0.1e-42.el7 GConf2 libx264-dev libvorbis-dev libx11-dev libav-tools libssl-dev libffi-dev wget ffmpeg xvfb x11vnc unzip ratpoison \
 && yum update 

ENV http_proxy=http://172.17.42.1:3128 https_proxy=http://172.17.42.1:3128 \
    ARTIFACTORY=10.40.250.118  WLP_HOME=/opt/IBM/WebSphere DATA_DIR=/mnt/ernie \
    HOME=/root LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 JAVA_HOME=/usr/java/default \
    JVM_ARGS="-Dhttps.proxyHost=172.17.42.1 -Dhttps.proxyPort=3128" 


#==============
# Back to sudo
#==============
USER root

ENV CPU_ARCH 64
ENV NORMAL_USER_HOME /home
ENV SEL_HOME ${NORMAL_USER_HOME}/selenium

#RUN yum install -y haveged rng-tools \
#  && service haveed start \
#  && update-rc.d haveged defaults \
#  && rm -rf /var/lib/apt/lists/*

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

#RUN yum localinstall google-chrome-stable_current_x86_64.rpm \
RUN rpm -i --force google-chrome-stable_current_x86_64.rpm


#==================
# Chrome webdriver
#==================
# How to get cpu arch dynamically: $(lscpu | grep Architecture | sed "s/^.*_//")
ENV CHROME_DRIVER_FILE "chromedriver_linux64.zip"
ENV CHROME_DRIVER_BASE chromedriver.storage.googleapis.com
ENV CHROME_DRIVER_VERSION "2.18"
# Gets latest chrome driver version. Or you can hard-code it, e.g. 2.15
RUN mkdir -p /home/tmp \
 && mkdir -p /home/selenium
  # 1st dup line CHROME_DRIVER_VERSION is just to invalidate docker cache
  # && CHROME_DRIVER_VERSION=$(curl 'http://chromedriver.storage.googleapis.com/LATEST_RELEASE' 2> /dev/null) \
#RUN export CHROME_DRIVER_URL="${CHROME_DRIVER_BASE}/${CHROME_DRIVER_VERSION}/${CHROME_DRIVER_FILE}"
RUN cd /home/tmp \
 && wget -O chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/2.18/chromedriver_linux64.zip \
 && cd /home/selenium \
&& rm -rf chromedriver \
&& unzip /home/tmp/chromedriver_linux64.zip \
&& rm /home/tmp/chromedriver_linux64.zip \
&& mv /home/selenium/chromedriver /home/selenium/chromedriver-2.18 \
&& chmod 755 /home/selenium/chromedriver-2.18 \
&& ln -s /home/selenium/chromedriver-2.18 /home/selenium/chromedriver

#==========
# Selenium
#==========
ENV SEL_MAJOR_MINOR_VER 2.47
ENV SEL_PATCH_LEVEL_VER 1
RUN  mkdir -p /home/selenium \
  && cd /home/selenium \
#  && export SELBASE="http://selenium-release.storage.googleapis.com" \
#  && export SELPATH="${SEL_MAJOR_MINOR_VER}/selenium-server-standalone-${SEL_MAJOR_MINOR_VER}.${SEL_PATCH_LEVEL_VER}.jar" \
  && wget http://10.40.250.118/artifactory/simple/libs-release-local/org/seleniumhq/selenium/selenium-server-standalone/2.47.1/selenium-server-standalone-2.47.1.jar -O selenium-server-standalone.jar

ADD start-selenium /usr/local/bin/start-selenium
ADD stream-mkv /usr/local/bin/stream-mkv

# Expose selenium and VNC ports
EXPOSE 4444
EXPOSE 5900

# Start XVFB and Selenium
WORKDIR /usr/local/selenium
CMD ["start-selenium"]
