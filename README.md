MCollectiveAgentActionBackground
================================

An example of how to write MCollective Agents to run in background. 

## Example

### Execute action via RPC.
```
$ mco rpc bg run_bg -I node -j
{"status": 0, "result": "2434"}
```

### Fetch status of action via RPC.

```
$ mco rpc bg status pid=2434 operation=run_bug -I node -j
{"status": null, "result": "running"}
```

```
$ mco rpc bg status pid=2434 operation=run_bug -I node -j
{"status": 0, "result": ""}
```

## Issues

There's a somewhat harmless issue with this approach. Since the parent of the forked child process does not wait for the process to end, there is a good chance of the child process turning into a zombie process. 

There is a fix for this problem which requires defining `SIG_IGN` as the default disposition for the `SIGCHLD` signal. This causes the Kernel to reap the zombie process. This can easily be done by using the following statement in Ruby: `Signal.trap("SIGCHLD", "SIG_IGN")`. 
