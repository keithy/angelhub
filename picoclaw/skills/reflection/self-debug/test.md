# Test Plan

## Debug Commands
- [ ] Logs are accessible
  ```sh
  debug.sh logs 50
  debug.sh logs-errors 20
  ```
- [ ] Debug endpoints respond / Health check works
  ```sh
  debug.sh service-status
  debug.sh config-status  # runs 'picoclaw status'
  ```

## Troubleshooting

If these do not work check that `~/.picoclaw/bin` is on the PATH.
Check that `picoclaw-manager service status` works, OR `picoclaw service status`
