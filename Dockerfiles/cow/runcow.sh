#!/usr/bin/env bash

docker run -d --privileged --dns=127.0.0.1 -v $HOME/.cow:/.cow -p 7777:7777 cow
