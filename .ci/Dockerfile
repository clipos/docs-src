# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2019 ANSSI. All rights reserved.

FROM debian:10-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq \
	&& apt-get upgrade -y -qq \
	&& apt-get install -y -qq git python3-sphinx python3-sphinx-rtd-theme \
	&& apt-get clean
