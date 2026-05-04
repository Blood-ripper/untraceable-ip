FROM debian:bullseye-slim

LABEL maintainer="your-github-username"
LABEL description="Tor IP Changer - Educational Project"

RUN apt-get update && apt-get install -y \
    tor \
    curl \
    netcat-openbsd \
    python3 \
    python3-pip \
    && pip3 install requests stem PySocks \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Expose Tor SOCKS and control ports
EXPOSE 9050 9051

RUN chmod +x untraceable-ip.sh scripts/*.sh

CMD ["bash", "untraceable-ip.sh", "--start"]
