# Deploy microshift with terraform

This collections of playbooks/HCL files will permits you to deploy easily microshift on a cloud provider

## Requirements

- Ansible <= 2.10
- Terraform <= 1.2.6
- oc <= 4.8

```shell
$ ansible-galaxy install -r requirements.yml
```

## Deployment on Hetzner

Export HCLOUD_TOKEN

```shell
$ export HCLOUD_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxx
```

Deploy microshift

```shell
$ ansible-playbook deploy_microshift.yml
```

Validate deployment

```shell
$ oc get po -A
```

>Pods should all be in `Running` state

## Delete Microshift instance

```shell
$ ansible-playbook deploy_microshift.yml -e tf_state=absent
```
