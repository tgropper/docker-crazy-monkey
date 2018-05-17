# docker-crazy-monkey

Runs a `crazy-monkey` that randomly kills running docker containers.

## Usage

`./crazy-monkey.sh [OPTIONS]`

**Options:**

|ARGS|Description|Default|
-----|-----------|-------|
|`--dead-time`|Time (in seconds) the dead container should remain stopped|1|
|`--sleep-time`|Time (in seconds) between each kill|5|
|`--parallel`|Number of parallel kill executions|3|
|`--containers-regex`|Regex to define the list of containers to use|.|
