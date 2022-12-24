ARG         base=alpine

###

FROM        ${base} as build

ARG         version=22.12.0
ARG         repo=freedesktop/poppler

RUN         apk add --no-cache --virtual .build-deps \
                build-base \
                cmake \
                ninja \
	            fontconfig-dev \
	            gobject-introspection-dev \
	            lcms2-dev \
	            libjpeg-turbo-dev \
	            libpng-dev \
                libxml2-dev \
                openjpeg-dev \
                openjpeg-tools \
                samurai \
                tiff-dev \
                zlib-dev \
                boost-dev \
                curl-dev && \
            wget -O - https://github.com/${repo}/archive/refs/tags/poppler-${version}.tar.gz | tar xz

WORKDIR     /poppler-poppler-${version}

RUN         cmake \
                -G Ninja \
                -DENABLE_BOOST=ON \
                . && \
            cmake --build . && \
            cmake --install .

###

FROM        ${base}

ENTRYPOINT  ["pdfinfo"]
CMD         ["--help"]

RUN         apk add --no-cache --virtual .run-deps \
                freetype \
                fontconfig \
                libjpeg-turbo \
                openjpeg \
                lcms2 \
                libpng \
                tiff

COPY        --from=build /usr/local/bin /usr/local/bin
COPY        --from=build /usr/local/include /usr/local/include
COPY        --from=build /usr/local/lib /usr/local/lib