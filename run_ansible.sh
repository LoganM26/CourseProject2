if [ -z "$1" ]; then
  echo "Usage: $0 <public_ip>"
  exit 1
fi

PUBLIC_IP="$1"
export ANSIBLE_HOST_KEY_CHECKING=False

ansible-playbook \
  -i "${PUBLIC_IP}," \
  -u ec2-user \
  --private-key ~/.ssh/id_rsa \
  ansible/site.yml
