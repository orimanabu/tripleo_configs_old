#!/bin/bash

key=fence_xvm.key

#dd if=/dev/urandom bs=512 count=1 of=${key}
#cp ${key} ${key}.orig
#base64 ${key} > ${key}.b64

key_b64="
KOE7wxRMpSrjcNtb0WofDc5ipV1XcXXqZdIfKWKBN4zfbqyYwfCv24tEeJbgz4J+ZrIZ9TJPSPDV
P7zwduYicjsRJrJvvJgBkoWh+vqdfWTPAoldDUJmc+muBM6NSg2Qkv2mXyfDL0HPVJcSxN/he+C0
lMgz24yTXt2byn+EAW7TawMTVpMeE3HFfgI5+4hKbr4D2wvp8ceEhhOJil0Ex9HgUvJzZaa+klqw
LAc90cJ0cjzfMV1sYQNSCKA5lL06HHaBmGhl8aa0oyQJA6CSuEghoEVweGujJipYquj9tp1ZQUOB
CXEogJh6GSNKcBLTrxH4Gxg21O7eb98qWpaPHFwoeiZTgnYBYOWBFqQMKreCOHvVNRDjZuvSqJat
9rbF0ZVUyzA3Yq2fIvoAh8ucuVllScGCB+3kNNY8BOLyBGdpqXx/JN2DtQHxXT4YXf0I4IrrUO9J
pUdng+Z4rOhMyGGX5hzNhr4uNhT0xLnZNOjQG+u3hYgznV7IUYE9Lf6yqGl53Pcc2WS25HfmNjap
Fh508lYNeAyCYjPsue8Cd7QLSPejxlUmXbPhUVvsfBiRJ1yZscwYcWiFX4eQ2hc1k+z9Q4+uJBCS
n54sWMJwTj8/hCvh+wbbrGoq0S6mHweJdyziEvhaQMgaZXeQBIu9y3Tch+J4fAcJjnWPqUO8F5M=
"

yum install -y fence-virt fence-virtd fence-virtd-libvirt fence-virtd-multicast

mkdir -p /etc/cluster
echo ${key_b64} | base64 -i -d - > /etc/cluster/${key}

cat > /etc/fence_virt.conf <<EOF
fence_virtd {
        listener = "multicast";
        backend = "libvirt";
        module_path = "/usr/lib64/fence-virt";
}

listeners {
        multicast {
                key_file = "/etc/cluster/fence_xvm.key";
                address = "225.0.0.12";
                family = "ipv4";
                interface = "virbr-foreman";
                port = "1229";
        }

}

backends {
        libvirt {
                uri = "qemu:///system";
        }

}
EOF
