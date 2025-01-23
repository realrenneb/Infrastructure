# Story
You recently joined the team of python developers that has been using docker-compose or bare bash scripts on VM deployments so far. Recently core infra team came up with the new infrastructure where they rolled out Kubernetes cluster that is now available for all development teams.

# Problem statement
There is a new app that has been developed by one of our junior developers. This app is a daemon app and while running, it is continuously producing some events to the external systems (in this particular assignment it is just imitating it, by logging the progress).
Your task is to prepare a Helm chart that could be deployed to the Kubernetes cluster.

# Expected output
Helm chart that manages the deployment of the "producer" app in production and test environments.

# Bonus point
- Cover corner cases such as restarts on failures, app hanging and not producing any events (aka zombie).
- Monitoring of the app, container, pod stats.
- As the development of the app can change and potentially some REST API might be added, having services resources would be beneficial
- Taking into consideration fault tolerance and scalability

# Final notes
To achieve some of the bonus points you might need to have some changes done in the app from the development. Try your best to inject any required changes in custom() function.