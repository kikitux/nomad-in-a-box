#!/usr/bin/env bash

systemctl enable vault.service
systemctl start vault.service 2>/dev/null
