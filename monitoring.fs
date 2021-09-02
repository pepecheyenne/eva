type    : agent.filesystem
label   : Filesystem - /
period  : 60
timeout : 10
details :
    target : /
alarms  :
    disk-size:
        label: Usage on /
        notification_plan_id: npTechnicalContactsEmail
        criteria: |
            if (percentage(metric['used'], metric['total']) > 90) {
                return new AlarmStatus(CRITICAL, 'Disk usage is above 90%, #{used} out of #{total}');
            }
            if (percentage(metric['used'], metric['total']) > 80) {
                return new AlarmStatus(WARNING, 'Disk usage is above 80%, #{used} out of #{total}');
            }
