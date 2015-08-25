FROM debian:wheezy
MAINTAINER Brady Wood

### SET UP
# BASE wheezy-backports O/S with some helpful tools
RUN echo "deb http://ftp.us.debian.org/debian wheezy-backports main" >> /etc/apt/sources.list
RUN apt-get -qq update
RUN apt-get -qqy install sudo wget lynx telnet nano curl

# JAVA and XVFB
RUN apt-get -qqy install openjdk-7-jre xvfb x11vnc
RUN apt-get -qqy install ratpoison ffmpeg iceweasel

ENV NORMAL_USER_HOME /home/${NORMAL_USER}
ENV CPU_ARCH 64
ENV SEL_HOME ${NORMAL_USER_HOME}/selenium

#==================
# Chrome webdriver
#==================
# How to get cpu arch dynamically: $(lscpu | grep Architecture | sed "s/^.*_//")
ENV CHROME_DRIVER_FILE "chromedriver_linux${CPU_ARCH}.zip"
ENV CHROME_DRIVER_BASE chromedriver.storage.googleapis.com
# Gets latest chrome driver version. Or you can hard-code it, e.g. 2.15
RUN mkdir -p ${NORMAL_USER_HOME}/tmp && cd ${NORMAL_USER_HOME}/tmp \
  # 1st dup line CHROME_DRIVER_VERSION is just to invalidate docker cache
  && CHROME_DRIVER_VERSION="2.18" \
  # && CHROME_DRIVER_VERSION=$(curl 'http://chromedriver.storage.googleapis.com/LATEST_RELEASE' 2> /dev/null) \
  && CHROME_DRIVER_URL="${CHROME_DRIVER_BASE}/${CHROME_DRIVER_VERSION}/${CHROME_DRIVER_FILE}" \
  && wget --no-verbose -O chromedriver_linux${CPU_ARCH}.zip ${CHROME_DRIVER_URL} \
  && cd ${SEL_HOME} \
  && rm -rf chromedriver \
  && unzip ${NORMAL_USER_HOME}/tmp/chromedriver_linux${CPU_ARCH}.zip \
  && rm ${NORMAL_USER_HOME}/tmp/chromedriver_linux${CPU_ARCH}.zip \
  && mv ${SEL_HOME}/chromedriver \
        ${SEL_HOME}/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 ${SEL_HOME}/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -s ${SEL_HOME}/chromedriver-${CHROME_DRIVER_VERSION} \
           ${SEL_HOME}/chromedriver

# Selenium
RUN mkdir /usr/local/selenium
RUN cd /usr/local/selenium && wget http://selenium-release.storage.googleapis.com/2.39/selenium-server-standalone-2.39.0.jar

ADD start-selenium /usr/local/bin/start-selenium
ADD stream-mkv /usr/local/bin/stream-mkv

# Expose selenium and VNC ports
EXPOSE 4444
EXPOSE 5900

# Start XVFB and Selenium
WORKDIR /usr/local/selenium
CMD ["start-selenium"]
