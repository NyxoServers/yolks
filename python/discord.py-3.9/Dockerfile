#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

FROM        --platform=$TARGETOS/$TARGETARCH python:3.9-alpine

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/NyxoServers/yolks"
LABEL       org.opencontainers.image.licenses=MIT

RUN         apk add --update --no-cache cmake make ca-certificates curl ffmpeg g++ gcc git openssl sqlite tar tzdata \
			&& apk add --update --no-cache clamav clamav-daemon clamav-libunrar \
			&& apk add --update --no-cache skopeo umoci \
			&& mkdir -p /mnt/unpacked_tools \
			&& skopeo copy docker://ghcr.io/nyxoservers/tools-cli:latest-full-release oci:/mnt/extracted:latest-full-release \
			&& umoci unpack --rootless --image /mnt/extracted:latest-full-release /mnt/unpacked \
			&& tar -xvf /mnt/unpacked/rootfs/ghcr_tools.tar.gz -C /mnt/unpacked_tools \
			&& chmod +x /mnt/unpacked_tools/tools \
			&& /mnt/unpacked_tools/tools version \
			&& mv /mnt/unpacked_tools/tools /bin/tools \
			&& rm -rf /mnt \
			&& adduser -D -h /home/container container \
			&& python -m pip install --upgrade pip


RUN chown -R container:container /usr/bin/freshclam /var/lib/clamav

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../commit_count.txt /commit_count.txt
COPY        ./../commit_message.txt /commit_message.txt
COPY        ./../freshclam.conf /freshclam.conf
COPY        ./../entrypoint.discord.sh /entrypoint.sh

CMD         [ "/bin/ash", "/entrypoint.sh" ]
