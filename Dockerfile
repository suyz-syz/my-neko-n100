FROM ghcr.io/m1k1o/neko/intel-microsoft-edge:latest

USER root

# 1. 更新源到 Bookworm 并安装 N100 所需驱动
RUN sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    intel-media-va-driver-non-free \
    libva-wayland2 libva-drm2 libva-x11-2 \
    gstreamer1.0-vaapi gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-base && \
    # 2. 【核心必杀技】物理删除 VP8 的 VAAPI 插件文件
    # 这样 GStreamer 扫描时就会发现 VP8 硬件编码彻底“失踪”，从而被迫转向 H.264
    rm -f /usr/lib/x86_64-linux-gnu/gstreamer-1.0/libgstvaapivp8.so && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 保持 root 运行，由内部 supervisord 降权
