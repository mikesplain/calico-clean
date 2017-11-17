#!/bin/bash

IFS=$'\n';
nodes=( $(calicoctl get nodes | grep -vi name) )

echo ""
echo "Current calico nodes"
for i in ${nodes[@]}; do
  echo $i
done

k8snodes=( $(kubernetes/client/bin/kubectl get nodes | awk '{print $1}' | grep -vi name | cut -d. -f1) )
echo ""
echo "Current Kubernetes Nodes"

for i in ${k8snodes[@]}; do
  echo $i
done

unset IFS

if [ "${#nodes[@]}" -eq "0" ] || [ "${#k8snodes[@]}" -eq "0" ]; then
  echo "Calico nodes or k8s nodes returned an error. Exiting."
  exit 1
fi

for cnode in ${nodes[@]}; do
  found=false
  for k8snode in ${k8snodes[@]}; do
    if [ "$k8snode" == "$cnode" ]; then
      echo "Calico node found in k8s. Moving on."
      found=true
    fi
  done

  if "$found"; then
    echo "Found $cnode in K8s. Leaving as is."
  else
    echo "Calico node $cnode not found in K8s. Removing from calico"
    calicoctl delete node $cnode
  fi
done

echo "Calico clean completed successfully."
