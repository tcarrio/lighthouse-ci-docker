# lighthouse-ci-docker

This repository houses a Docker image for working with Lighthouse CI.

## getting started

You can pull the image from Docker Hub by calling

```sh
docker pull @0x7463/lhci
```

The default CMD is `lhci autorun`, and will make use of the `lighthouserc.json` config.

The expected run directory is `/app`, so you can mount a volume to that location.

### example

You can run the `lhci` with a given config file by doing the following:

```sh
docker run --rm -it -v /path/to/lighthouserc.json:/app/lighthouserc.json @0x7463/lhci
```

## advanced

Most of the possibilities here involve the configuration options available with Lighthouse CI. Dive into their docs to get [more information on what you can do](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md), such as uploading to LHCI servers, combining multiple test runs, and more.

### example

For example, the first use case for this project was an automated test against a deployed site. This is called from a Jenkins pipeline and archives the results. This is likely the first time the page is accessed after deployment, and content is cached to CloudFront after being accessed, so to ensure that we are making use of the CDN for our test, we set `numberOfRuns` to 2. This case also runs in Docker in Docker, so we disable to GPU and don't bother working with the sandbox.

The `.lighthouserc.js` is as follows:

```js
const url = (() => {
  const targetUrl = process.env.TARGET_URL;
  if (typeof targetUrl !== "string" || !targetUrl) {
    throw new Error("Invalid URL!");
  }
  return targetUrl;
})();

module.exports = {
  ci: {
    // https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md#collect
    collect: {
      url,
      numberOfRuns: 2,
      settings: {
        chromeFlags: "--disable-gpu --no-sandbox",
      },
    },
    // https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md#assert
    assert: {
      // https://github.com/GoogleChrome/lighthouse/blob/v5.5.0/lighthouse-core/config/default-config.js#L375-L407
      assertions: {},
    },
    // https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md#upload
    upload: {
      target: "filesystem",
      outputDir: "/var/tmp/lighthouse-results",
      reportFilenamePattern: "lighthouse-report.%%EXTENSION%%",
    },
    // https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md#server
    server: {},
    // https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md#wizard
    wizard: {},
  },
};
```

With this, we can run a container testing a specific URL as follows:

```sh
docker run --rm \
  -v \$(pwd)/.lighthouserc.js:/app/.lighthouserc.js \
  -v \$(pwd)/.lighthouse-results:/var/tmp/lighthouse-results/ \
  -e TARGET_URL=https://google.com \
  @0x7463/lhci
```

## feedback

The initial scope of the project has been kept very minimal. Feel free to open an issue for questions or bugs, or pull request for enhancements.