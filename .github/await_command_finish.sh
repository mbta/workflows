#!/usr/bin/env bash
resource_group_name=$1
command_id=$2
plugin=$3
instance_ids=$(aws resource-groups list-group-resources --group-name "$resource_group_name" |
                   jq -r .ResourceIdentifiers[].ResourceArn |
                   grep -oE 'mi-[0-9a-f]+')

for instance_id in $instance_ids; do
    echo "checking $instance_id..."
    status=Pending
    while [[ $status =~ (Pending|InProgress|Delayed) ]]; do
        sleep 30
        status=$(aws ssm get-command-invocation --command-id "$command_id" --instance-id "$instance_id" |
                     jq -r .Status)
        echo "command $command_id, instance $instance_id: $status"
    done
    if [[ "$plugin" != "" ]]; then
        plugin_result=$(aws ssm get-command-invocation --command-id "$command_id" --instance-id "$instance_id" --plugin "$plugin")
        echo Output:
        echo "$plugin_result" | jq -r .StandardOutputContent
        error_result=$(echo "$plugin_result" |
                           jq -r .StandardErrorContent)
        if [[ "$error_result" != ""  ]]; then
            echo
            echo Error:
            echo "$plugin_result" | jq -r .StandardErrorContent
            echo "$error_result"
        fi
    fi
    if [[ "$status" != Success ]]; then
        exit 1
    fi
done
