FROM arm64v8/ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's|http://archive.ubuntu.com/ubuntu|http://mirror.kakao.com/ubuntu|g' /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y mate-desktop-environment-core \
qtcreator qtbase5-dev qt5-qmake cmake \
build-essential git \
htop libtbb-dev libboost-all-dev libopencv-dev \
libopencv-contrib-dev libeigen3-dev cmake-gui \
libqt5websockets5-dev openssh-server

# OrbbecSDK 설정 (v.1.8.3)
RUN git clone https://github.com/orbbec/OrbbecSDK.git && \
    cd OrbbecSDK && \
    git checkout v1.8.3 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    cp -r install/include/libobsensor /usr/local/include/libobsensor

# SSH 서버 설정
RUN mkdir /var/run/sshd
RUN echo 'root:rainbow' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH 접속 시 사용할 수 없는 `pam_loginuid.so` 설정 제거
RUN sed -i 's/session\s*required\s*pam_loginuid.so/#session required pam_loginuid.so/g' /etc/pam.d/sshd

# 포트 22 오픈
EXPOSE 22

# SSH 서비스 시작
CMD ["/usr/sbin/sshd", "-D"]