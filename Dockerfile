
FROM nvidia/cuda:11.7.1-devel-ubuntu20.04

WORKDIR /work/cupoch

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y tzdata
ENV TZ Asia/Tokyo

RUN apt-get update && apt-get install -y --no-install-recommends \
         curl \
         wget \
         build-essential \
         libxinerama-dev \
         libxcursor-dev \
         libglu1-mesa-dev \
         xorg-dev \
         cmake \
         python3-dev \
         python3-setuptools && \
     rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4.tar.gz \
    && tar zxvf cmake-3.18.4.tar.gz \
    && cd cmake-3.18.4 \
    && ./bootstrap -- -DCMAKE_USE_OPENSSL=OFF \
    && make && make install

RUN curl -sSL https://install.python-poetry.org | python3 -

ENV PATH $PATH:/root/.local/bin

COPY . .

RUN cd src/python \
    && poetry config virtualenvs.create false \
    && poetry run pip install -U pip \
    && poetry install

ENV PYTHONPATH $PYTHONPATH:/usr/lib/python3.8/site-packages

RUN mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_GLEW=ON -DBUILD_GLFW=ON -DBUILD_PNG=ON -DBUILD_JSONCPP=ON \
    && make pip-package \
    && pip install lib/python_package/pip_package/*.whl
