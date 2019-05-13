#!/usr/bin/env sh
### Define constants
true; PTS_TRUE=$?
false; PTS_FALSE=$?
PTS_ERROR=2

### Debug settings
PTS_DEBUG=${DEBUG:-0}  # 0: Disabled 1: Enabled

export PTS_TRUE
export PTS_FALSE
export PTS_ERROR
export PTS_DEBUG