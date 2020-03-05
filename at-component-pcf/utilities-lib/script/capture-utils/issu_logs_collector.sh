#!/bin/bash

collectPuppetLogsFromAllVMs() {
    #echo "Starting puppet log capture..."
    rm -rf /tmp/puppet_logs
    mkdir -p /tmp/puppet_logs
    for NH in `hosts-all.sh`
    do
        echo $NH
        fileName=${NH}_puppet.log
        #echo "File name = ${fileName}"
        #echo "scp root@$NH:/var/log/puppet.log /tmp/puppet_logs/${fileName}"
        scp root@$NH:/var/log/puppet.log /tmp/puppet_logs/${fileName}
    done
    tar -czf /tmp/puppet_logs.tar.gz /tmp/puppet_logs
    echo "puppet log collection complete."
}

collectWHISPERLogsFromAllVMs() {
    rm -rf /tmp/whisper_logs
    mkdir -p /tmp/whisper_logs
    for NH in `hosts-all.sh`
    do
        echo $NH
        fileName=${NH}_whisper.log
        scp root@$NH:/var/log/whisper.log /tmp/whisper_logs/${fileName}
    done
    tar -czf /tmp/whisper_logs.tar.gz /tmp/whisper_logs
    echo "WHISPER log collection complete."
}

collectVM-InitLogsFromAllVMs() {
    rm -rf /tmp/vm-init_logs
    mkdir -p /tmp/vm-init_logs
    for NH in `hosts-all.sh`
    do
        echo $NH
        fileName=${NH}_vm-init.log
        scp root@$NH:/var/log/vm-init.log /tmp/vm-init_logs/${fileName}
    done
    tar -czf /tmp/vm-init_logs.tar.gz /tmp/vm-init_logs
    echo "vm-init log collection complete."
}
collectPuppetLogsFromAllVMs
collectWHISPERLogsFromAllVMs
collectVM-InitLogsFromAllVMs
