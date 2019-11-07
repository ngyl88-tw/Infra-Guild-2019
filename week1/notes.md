## Linux Commands

- `ps -ef -u <user>` list processes with user

- `systemctl start hello.service` in bootstrap.sh doesn't work, while `systemctl start hello` will work.

- What's the diff between `systemctl start` vs `systemctl enable`(Enable it to run at boot)?
Ref: https://medium.com/@benmorel/creating-a-linux-service-with-systemd-611b5c8b91d6

## Vagrant Notes

## Other Functional Notes
- `hello.service` vs `Java`
    - Using `spring.config.name` to load `test.properties` will yields `null` in the properties
    - Properties are injected successfully using `spring.config.location`