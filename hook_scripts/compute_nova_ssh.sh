#!/bin/bash

workdir=/root/work
mkdir -p ${workdir}

### user nova ssh settings on compute nodes
logger -t post-script "### (nova ssh) preparing"

private_key_file=nova_id_rsa
private_key_contents="-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA1NBmdAZhekpUcdb/9eM3Hpxm8rHqrw8rFzyMt0BcTiBoxSnv
Rh6cacM1pbTCutpzmLL8UauSG4hPlaUT0iysBCEsgwws0Iya3TcTSF2QlfiTW+jq
kzpuGCl5u4qot+qhJJkOqNuGC4EdCxg2liquNZvnaO/atO+hxuGDJcavnVJMFEAn
M7eMRTuLoQk2uM6gm4GpT7n9t1jT0TmA8uN4Ryqr4LUGx3UsXWVgDtUmBlPvQnJ/
Em4eWZg7uLaongJ5ppBloEGao6CaTOb4S2xxQd23ytUcp5Tmt36gLCmtWu7Bh53m
BjHBtSk6wKcvQ/DvvwRZg/fmlXvk92axJ37W3QIDAQABAoIBAQCWTgY+Zg9Mvti7
en1XXj4c2ZwAR1aYg58Mj1BXURage1VkA4UiQhZ4wE3QlkV+kTFZpPh+ei38Uh7b
czb3l2N6my+D8wJn3Ra3rOFql+K5eVIidPPQPlFpsUlwArO9CfL8FTn8Wudmkq8/
mb9b+hMGe/FJ9TXD2weonrfw404/TokN1zykFyRR+Y4aN8ffTvBg/ORIPT6OXj5F
T0V7wqdhKLptQStQ2/nb0AKygWAofw8XPqocxdmUKsSWZC5oS+L0/WmA2lCV9bLz
n4GuAPlxRhpkr4W2/6LP81AIweSSDJk/CikqUD5mJne+9OUaeG0fBdwGey9t29ks
FBYR1NQlAoGBAPwCTNvOKPxqT+lR43GJLqoeDFLzrj8ZB/PICHK8O+bz9pVq1pB5
++IP7kmpPys0RYo+XV8EGthDTdDBGcTivkVDi/NnfkuHfasEg0lj2gvD+LKY8qOF
unuD84WCho4qNRzNekVzuKmvLJ4Fk6XOJcHmUy9K5DbK1weVcB8/lWdrAoGBANgv
MfXYiqNtfZEhzUivCAZf6tX2oFbetgoTyn7DZjoiZ8kbphQy3/9B7zNdI9r8iVKM
Fu6JfpJfP/oq4kHBqIZY2ZHDDFyb3dy1eBQsslQL6ipq7zVLkcS1BauZnXkhjbHe
vTmZSNtIbvc9DjdQ5Tbi/Yb1xFlhJ7zhC+EDGfTXAoGANq8VGHlC4Yr8Lifrz74x
1w5QJEvmWqDG3fphAuyfnvz/W+rkBlPB+Yr1bRyBrZFZKadgwXZ1kMoB/7N3MQb2
vLbsjnO9rwwGk+6Vwn4dWYI73B1eQWeKULUQSb9KDV1RSx+3UYzL3F47s0qIgGkc
PlgJYvDAVrdrM6UUwGMeu2MCgYARryKmGrWUktNPuPUi+fZtFxGNuSP6lzNK9b19
yxwkq0XUJKfcRSEfr1QS3o6dTkUpdH43uxWYgaQpIbLqcB4KB2Cc1NjBBpsKf+m3
tMRNrb/VAnRY5rqg3bH+DI3eJ8mAgFj4Sjq0fWNeZCcyjTKC3+SfUqFiMlle0QX4
vRk1dwKBgDHQWEm1QWz+d03P++NtOaj1cKpb/eB9Pqcx41+DrkqX9D4kJlKxDmLv
DlhShfW8Ml27E82Liz5s5C4BYpLj2m9KSnwXc/U0QMCYOciye87GiMI7/Q54qdJZ
KxQOVGhJoLM5HgGbJpEyn/DDQUIToVM86qESja734P6AfkO2hf3p
-----END RSA PRIVATE KEY-----"

public_key_file=nova_id_rsa.pub
public_key_contents="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU0GZ0BmF6SlRx1v/14zcenGbyseqvDysXPIy3QFxOIGjFKe9GHpxpwzWltMK62nOYsvxRq5IbiE+VpRPSLKwEISyDDCzQjJrdNxNIXZCV+JNb6OqTOm4YKXm7iqi36qEkmQ6o24YLgR0LGDaWKq41m+do79q076HG4YMlxq+dUkwUQCczt4xFO4uhCTa4zqCbgalPuf23WNPROYDy43hHKqvgtQbHdSxdZWAO1SYGU+9Ccn8Sbh5ZmDu4tqieAnmmkGWgQZqjoJpM5vhLbHFB3bfK1RynlOa3fqAsKa1a7sGHneYGMcG1KTrApy9D8O+/BFmD9+aVe+T3ZrEnftbd stack@adc-r3-deploy001.rdcloud.bi-rd.jp"

nova_home=/var/lib/nova
nova_ssh=${nova_home}/.ssh

echo "${private_key_contents}" > ${workdir}/${private_key_file}
echo "${public_key_contents}" > ${workdir}/${public_key_file}

logger -t post-script "### (nova ssh) install ssh keys for user nova"
mkdir -p ${nova_ssh}
cp ${workdir}/${private_key_file} ${nova_ssh}/id_rsa
chmod 600 ${nova_ssh}/id_rsa
cp ${workdir}/${public_key_file} ${nova_ssh}/id_rsa.pub
chmod 644 ${nova_ssh}/id_rsa.pub
cp ${workdir}/${public_key_file} ${nova_ssh}/authorized_keys
chmod 644 ${nova_ssh}/authorized_keys
echo 'StrictHostKeyChecking no' > ${nova_ssh}/config
chown -R nova:nova ${nova_ssh}

logger -t post-script "### (nova ssh) change login shell for nova to /bin/bash"
usermod -s /bin/bash nova
