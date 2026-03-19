FROM ghcr.io/m1k1o/neko/intel-microsoft-edge:latest

USER root

# 1. 彻底删除旧镜像残留的所有第三方仓库（这是解决 Exit Code 100 的关键）
RUN rm -rf /etc/apt/sources.list.d/* && \
    # 2. 强制改写主源为 Bookworm (Debian 12)
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    # 3. 更新并安装 N100 必须的新版驱动
    apt-get update && \
    apt-get install -y --no-install-recommends \
    intel-media-va-driver-non-free \
    libva-wayland2 libva-drm2 libva-x11-2 \
    gstreamer1.0-vaapi gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-base && \
    # 4. 物理剔除 VP8 插件，防止 N100 误判（N100 硬件只支持 VP8 解码不支持编码）
    find /usr/lib -name "libgstvaapivp8.so" -delete && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 保持 root 启动，内部 supervisord 会处理权限
