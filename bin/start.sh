#!/usr/bin/env bash
cd "$(dirname "$0")/.."
elixir -S mix run --no-halt
