# ddev-localtunnel

[![tests](https://github.com/atj4me/ddev-localtunnel/actions/workflows/tests.yml/badge.svg)](https://github.com/atj4me/ddev-localtunnel/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

A DDEV addon that provides [localtunnel](https://github.com/localtunnel/localtunnel) functionality to share your DDEV project publicly via a secure tunnel.

This addon serves as an alternative to ngrok for getting shareable URLs for your DDEV development environment.

## What does this addon do?

This addon adds a `ddev lt` command that:
- Creates a secure tunnel to your DDEV project using localtunnel
- Provides a public URL to share your development site
- Works with any DDEV project without additional configuration

## Installation

```bash
ddev get atj4me/ddev-localtunnel
ddev restart
```

## Usage

### Start sharing your project
```bash
ddev lt share
```

This will:
1. Start the localtunnel service
2. Create a public tunnel to your DDEV project
3. Display the shareable URL

### Check tunnel status
```bash
ddev lt status
```

### Stop sharing
```bash
ddev lt stop
```

## Example Output

```bash
$ ddev lt share
Starting localtunnel for my-project...
Waiting for tunnel to establish...

🌐 Your project is now publicly accessible at:
   https://my-project.loca.lt

📌 This tunnel will remain active until you run 'ddev lt stop'
⚠️  Warning: Your development site is now publicly accessible!
```

## Security Considerations

- **Public Access**: When active, your development site becomes publicly accessible on the internet
- **Development Data**: Ensure you're not exposing sensitive development data
- **Temporary Use**: It's recommended to stop the tunnel when not needed

## Comparison with ngrok

| Feature | localtunnel | ngrok |
|---------|-------------|-------|
| Cost | Free | Free tier available |
| Custom subdomains | Limited | Pro feature |
| Setup complexity | Simple | Requires account |
| Reliability | Good | Excellent |

## Troubleshooting

### Tunnel not establishing
```bash
# Check container logs
docker logs ddev-$(ddev config --show | grep name | cut -d':' -f2 | xargs)-localtunnel

# Restart the tunnel
ddev lt stop
ddev lt share
```

### Port conflicts
The addon automatically uses port 80 from the web container, which should work in most DDEV configurations.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
