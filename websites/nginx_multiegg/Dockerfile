FROM alpine:latest

RUN apk --update --no-cache add curl ca-certificates nginx
RUN apk add php8 php8-xml php8-exif php8-fpm php8-session php8-soap php8-openssl php8-gmp php8-pdo_odbc php8-json php8-dom php8-pdo php8-zip php8-mysqli php8-sqlite3 php8-pdo_pgsql php8-bcmath php8-gd php8-odbc php8-pdo_mysql php8-pdo_sqlite php8-gettext php8-xmlreader php8-bz2 php8-iconv php8-pdo_dblib php8-curl php8-ctype php8-phar php8-fileinfo php8-mbstring php8-tokenizer php8-simplexml

RUN apk add --update --no-cache skopeo umoci \
    && mkdir -p /mnt/unpacked_tools \
    && skopeo copy docker://ghcr.io/nyxoservers/tools-cli:latest-full-release oci:/mnt/extracted:latest-full-release \
    && umoci unpack --rootless --image /mnt/extracted:latest-full-release /mnt/unpacked \
    && tar -xvf /mnt/unpacked/rootfs/ghcr_tools.tar.gz -C /mnt/unpacked_tools \
    && chmod +x /mnt/unpacked_tools/tools \
    && /mnt/unpacked_tools/tools version \
    && mv /mnt/unpacked_tools/tools /bin/tools \
    && rm -rf /mnt

COPY --from=composer:latest  /usr/bin/composer /usr/bin/composer

USER container
ENV  USER container
ENV HOME /home/container

WORKDIR /home/container

COPY        ./../commit_count.txt /commit_count.txt
COPY        ./../commit_message.txt /commit_message.txt
COPY        ./freshclam.conf /freshclam.conf
COPY        ./entrypoint.sh /entrypoint.sh


CMD ["/bin/ash", "/entrypoint.sh"]
