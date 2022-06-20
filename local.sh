#!/usr/bin/env sh
hugo -D
pagefind --site public --output-path "static/pagefind"
hugo server -D
