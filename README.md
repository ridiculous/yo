Yo
===

Runs a ruby process as a daemon that traps interrupt signal to cleanup some files before shutting down

## Usage

Start a process in the background

```bash
bundle exec bin/wb -d
```

Monitor

```ruby
tail -f log/wb.log
```

Terminate

```bash
kill -INT `cat tmp/pids/wb.pid`
```

### License

MIT