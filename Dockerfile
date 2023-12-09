FROM ubuntu:22.04 as build

# install deps
RUN \
	   apt-get update \
	&& DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
		wget \
		python3 \
		git \
		build-essential \76.1
		cmake \
		tclsh \
		zip \
		zstd

COPY . /minetest-wasm

# Build minetest-wasm
RUN \
	   cd /minetest-wasm \
	&& ls -la \
        && ./install_emsdk.sh \
	&& ./build_all.sh

FROM httpd:2.4
RUN sed -i '/LoadModule rewrite_module/s/^#//g' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's#AllowOverride [Nn]one#AllowOverride All#' /usr/local/apache2/conf/httpd.conf
	
COPY --from=build /minetest-wasm/www/ /usr/local/apache2/htdocs/

# https://minetest.org/wasm/?address=76.147.68.71&port=30000&name=Tama&password=mypassword&go


# location ~ wasm {
#     root /var/www/something.org;
#     add_header 'Cross-Origin-Embedder-Policy' 'require-corp';
#     add_header 'Cross-Origin-Opener-Policy' 'same-origin';
#     add_header 'Cache-Control' 'no-cache, no-store, must-revalidate';
#     add_header 'Pragma' 'no-cache';
#     add_header 'Expires' '0';
# }