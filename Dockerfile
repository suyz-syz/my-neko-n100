# 使用官方 Intel Edge 镜像作为底座
FROM ghcr.io/m1k1o/neko/intel-microsoft-edge:latest

USER root

# 1. 临时更换为 Debian Bookworm 软件源，以获取 23.x+ 版本的 Intel 驱动
RUN sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list && \
    apt-get update && \
    # 2. 安装适配 N100 的最新硬件加速驱动和库
    apt-get install -y --no-install-recommends \
    intel-media-va-driver-non-free \
    libva-wayland2 \
    libva-drm2 \
    libva-x11-2 \
    vainfo \
    gstreamer1.0-vaapi && \
    # 3. 清理缓存，保持镜像精简
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 切回 neko 用户运行程序
USER neko
