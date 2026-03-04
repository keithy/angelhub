# Test Plan

## Config Loading
- [ ] Config file parses correctly
- [ ] Environment variables override defaults

## Service Management
- [ ] `picoclaw config` shows current config
- [ ] Service restarts with new config
- [ ] Invalid config is rejected

## Auto-Rollback
- [ ] Rollback triggers on failed restart
- [ ] Previous config restored
