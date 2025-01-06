# Get the join command :
join_command=$(ssh -o StrictHostKeyChecking=no -i private-key.pem ubuntu@10.100.10.7 "kubeadm token create --print-join-command")

# Execute the join command on the worker node :
sudo $join_command