#!/bin/bash
# {{ ansible_managed }}
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Location where aurora-scheduler.zip was unpacked.
AURORA_SCHEDULER_HOME='{{ aurora_lib_dir }}/{{ aurora_version }}'

# Flags that control the behavior of the JVM.
JAVA_OPTS=(
  -server
  # Location of libmesos-XXXX.so / libmesos-XXXX.dylib
  -Djava.library.path='{{ mesos_lib_dir }}'

{% for jvm_flag in aurora_jvm_flags %}
  {{ jvm_flag }}
{% endfor %}
)

# Flags control the behavior of the Aurora scheduler.
# For a full list of available flags, run bin/aurora-scheduler -help
AURORA_FLAGS=(
  -cluster_name='{{ aurora_cluster_name }}'

  # Ports to listen on.
  -http_port={{ aurora_http_port }}

  -native_log_quorum_size='{{ aurora_native_log_quorum_size }}'

  -zk_endpoints="$(cat {{ aurora_conf_dir }}/zk)"
  -mesos_master_address=''

  -serverset_path='{{ aurora_serverset_zk_path }}'
  -native_log_zk_group_path='{{ aurora_native_log_zk_path }}'

  -native_log_file_path="$AURORA_SCHEDULER_HOME/db"
  -backup_dir="$AURORA_SCHEDULER_HOME/backups"

  -thermos_executor_path='{{ thermos_bin_dir }}/{{ aurora_version }}/thermos_executor.pex'
  -gc_executor_path='{{ thermos_bin_dir }}/{{ aurora_version }}/gc_executor.pex'

  -vlog='{{ aurora_log_level }}'

  # Extra flags:
{% for extra_flag in aurora_extra_flags %}
  {{ extra_flag }}
{% endfor %}
)

# Environment variables control the behavior of the Mesos scheduler driver (libmesos).
export GLOG_v=0
export LIBPROCESS_PORT={{ aurora_libprocess_port }}

JAVA_OPTS="${JAVA_OPTS[*]}" exec "$AURORA_SCHEDULER_HOME/bin/aurora-scheduler" "${AURORA_FLAGS[@]}"
