FROM ghcr.io/m1k1o/neko/intel-microsoft-edge:latest

USER root

# 1. 彻底清理掉旧的、冲突的源，并重新写入纯净的 Bookworm 源
# 加入了 non-free-firmware，这是 N100 驱动安装成功的关键
RUN rm -rf /etc/apt/sources.list.d/* && \
    echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    apt-get update && \
    # 2. 安装驱动和 GStreamer 插件
    apt-get install -y --no-install-recommends \
    intel-media-va-driver-non-free \
    libva-wayland2 libva-drm2 libva-x11-2 \
    gstreamer1.0-vaapi gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-base && \
    # 3. 【核心必杀技】物理删除 VP8 硬件插件文件
    # 使用 find 寻找路径，确保一定能删掉，逼迫 Neko 回退到 H.264
    find /usr/lib -name "libgstvaapivp8.so" -delete && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 保持默认启动逻辑
