# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial DDEV addon implementation for localtunnel
- `ddev lt share` command to start localtunnel and share project publicly
- `ddev lt stop` command to stop the localtunnel service
- `ddev lt status` command to check tunnel status
- Docker Compose service for localtunnel using Node.js Alpine image
- Comprehensive documentation in README.md
- Test script for addon structure validation
- Security warnings about public accessibility

### Features
- Automatic subdomain assignment based on DDEV site name
- Integration with DDEV's docker network
- Detailed status reporting with public URL display
- Error handling and user-friendly messages
- Cross-platform compatibility (Linux, macOS, Windows with WSL)