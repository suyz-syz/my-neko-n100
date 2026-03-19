# 使用官方 Intel Edge 镜像作为底座
FROM ghcr.io/m1k1o/neko/intel-microsoft-edge:latest

USER root

# 1. 彻底清理旧的第三方仓库，防止 GPG 密钥报错导致更新中断
RUN rm -rf /etc/apt/sources.list.d/* && \
    # 2. 将主源强行替换为 Debian Bookworm (Debian 12)，以支持 N100 硬件
    sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list && \
    # 3. 更新并安装 N100 所需的新版驱动 + GStreamer 硬件加速全家桶
    apt-get update && \
    apt-get install -y --no-install-recommends \
    intel-media-va-driver-non-free \
    libva-wayland2 \
    libva-drm2 \
    libva-x11-2 \
    vainfo \
    gstreamer1.0-tools \
    gstreamer1.0-vaapi \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-base && \
    # 4. 清理缓存，减小镜像体积
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- 关键修正 ---
# 不要在这里写 USER neko。
# 必须让容器以 root 启动，内部的 supervisord 才能成功执行权限降级逻辑。
