#!/bin/sh

echo "ECS_CLUSTER=${ecs_cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_AVAILABLE_LOGGING_DRIVERS=[\"awslogs\",\"splunk\",\"json-file\",\"none\"]" >> /etc/ecs/ecs.config
echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=1h" >> /etc/ecs/ecs.config

# Clean up docker images and containers daily
sudo cat >/etc/cron.daily/dockerprune <<EOF
#!/bin/sh \
docker system prune -a -f
EOF
sudo chmod +x /etc/cron.daily/dockerprune

# curl -u ${artifactory_creds} ${crowdstrike_pkg_path}/${crowdstrike_pkg} --output ${crowdstrike_pkg}
# curl -u ${artifactory_creds} ${crowdstrike_pkg_path}/${qualys_pkg} --output ${qualys_pkg}
# sudo yum install -y ${crowdstrike_pkg}
# sudo /opt/CrowdStrike/falconctl -s --cid=FB1C296F5C7A447B99F1AE77C7E3A553-6B
# sudo service falcon-sensor start
# sudo yum install -y ${qualys_pkg}
