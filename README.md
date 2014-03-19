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
