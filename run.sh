#!/bin/bash

pwsh ./scripts/bootstrap.ps1

if [ "$action" = "deploy" ]; then
    pwsh ./scripts/deploy.ps1
elif [ "$action" = "delete" ]; then
    pwsh ./scripts/delete.ps1
else
    echo "Invalid action"
    exit 1
fi
