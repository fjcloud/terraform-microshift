# Deploy microshift with terraform

This collections of playbooks/HCL files will permits you to deploy easily microshift on a cloud provider

## Requirements

- Ansible >= 2.10
- Terraform >= 1.2.6
- oc >= 4.8
- podman >= 4.1.1

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
$ ansible-playbook deploy_microshift.yml -e provider=hetzner
```

## Deployment on libvirt

Download Fedora CoreOS

```shell
$ FCOS_URL=$(curl -s https://builds.coreos.fedoraproject.org/streams/stable.json | jq -r '.architectures.x86_64.artifacts.qemu.formats."qcow2.xz"'.disk.location)
$ curl -s ${FCOS_URL} | xzcat > fcos-latest.qcow2
```

Deploy microshift

```shell
$ ansible-playbook deploy_microshift.yml -e provider=libvirt
```

## General Config

Export KUBECONFIG

```shell
$ export KUBECONFIG=../kubeconfig
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
