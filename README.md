# Dispatcher Docker Image

Docker image containing Dispatcher for AEM.

## Building the image

Build the image with

```bash
docker build -t public.ecr.aws/cord-tools/dispatcher:<version-tag> .

# Example
docker build -t public.ecr.aws/cord-tools/dispatcher:4.3.3 .
```

## Running the image

Run dispatcher with the default configuration using

```
docker run -p 8080:80 public.ecr.aws/cord-tools/dispatcher:<version-tag>

# Example
docker run -p 8080:80 public.ecr.aws/cord-tools/dispatcher:4.3.3
```

Once running, visit http://localhost:8080 in a browser.

### Environment Variables

Environment variables can be used to configure which publish instance dispatcher
is using as a renderer.

```
docker run -p 8080:80 -e PUBLISH_DOMAIN=domain.tld -e PUBLISH_PORT=5503 public.ecr.aws/cord-tools/dispatcher:4.3.3
```

#### `PUBLISH_DOMAIN`

The domain/ip for publish. Defaults to `localhost`

#### `PUBLISH_PORT`

The port for publish. Defaults to `4503`

#### `AUTO_RELOAD`

Set to `true` to gracefully reload apache when anything in `/etc/httpd/conf.d/`
changes. Any other value disables the auto reload. Default is set to `true`.

## Configuring Dispatcher

Dispatcher can be configured by placing the config files in the correct spots.
This can be done using a dockerfile like this:

```
FROM public.ecr.aws/cord-tools/dispatcher:4.3.3
COPY ./dispatcher.conf /etc/httpd/conf.d/
COPY ./dispatcher.any /etc/httpd/conf.d/
```

All configuration files in `/etc/httpd/conf.d/` will be automatically
included. Rewrites and other apache configuration can be added this way.

### dispatcher.conf

The `dispatcher.conf` file is located in `/etc/httpd/conf.d/`. See the
[official documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/getting-started/dispatcher-install.html#apache-web-server-configure-apache-web-server-for-dispatcher) for all options.

### dispatcher.any

The `dispatcher.any` is located in `/etc/httpd/conf.d/`. See the
[official documentation](https://docs.adobe.com/content/help/en/experience-manager-dispatcher/using/configuring/dispatcher-configuration.html) for all options.

#### Cache directory

The cache directory is set to `/var/www/html`.
