#!/bin/bash
sleep 5
mount -t cgroup -omemory memcg /dev/memcg_test/
