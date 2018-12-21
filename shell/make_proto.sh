#!/bin/bash
protoc -I cs_common/proto -ocs_common/proto/proto.pb `find -L cs_common/proto  -name "*.proto"`