# 使用官方 Intel Edge 镜像
FROM ghcr.io/m1k1o/neko/intel-microsoft-edge:latest

USER root

# 1. 彻底清理旧的第三方仓库，防止 GPG 密钥报错导致更新中断
RUN rm -rf /etc/apt/sources.list.d/* && \
    # 2. 将主源强行替换为 Debian Bookworm (Debian 12)
    sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list && \
    # 3. 更新并安装 N100 所需的新版驱动
    apt-get update && \
    apt-get install -y --no-install-recommends \
    intel-media-va-driver-non-free \
    libva-wayland2 \
    libva-drm2 \
    libva-x11-2 \
    vainfo \
    gstreamer1.0-vaapi && \
    # 4. 清理，减小体积
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER neko
