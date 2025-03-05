---
title: Deploy to web
weight: 4
---

# Deploy to web

This page will show you how to deploy your Flutter application as a web app (or
PWA).

There are two options, and you can pick either depending on taste.

First test out that your app can actually be build for web.

```sh
flutter build web
```

If it gives an error then your project can't be deployed.
Please check that all the packages and plugins you use in the project support
**web**.

You can see the supported platforms at the top of the <https://pub.dev> page
for the package/plugin.
Here is an example.

![Supported platforms for BLoC on pub.dev](../images/pubdev-header.png)

_As you can see BLoC works on Android, iOS, Linux, macOS, Web and Windows._

## Firebase Hosting

Deploy Flutter app for web using Firebase hosting.

<iframe src="https://easv.cloud.panopto.eu/Panopto/Pages/Embed.aspx?id=5e55e1da-b61c-44de-b344-b0fc010fe900&autoplay=false&offerviewer=true&showtitle=true&showbrand=true&captions=false&interactivity=all" height="405" width="720" style="border: 1px solid #464646;" allowfullscreen allow="autoplay" aria-label="Panopto Embedded Video Player"></iframe>

## GitHub Pages

Add a new workflow file (`.github/workflows/deploy.yml`) to your GitHub
repository with the following content.

```yaml
name: Web deploy
on: push
permissions:
  contents: write
jobs:
  web_deploy:
    name: Deployment
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: "stable"
          cache: true
          cache-key: "flutter-:os:-:channel:-:version:-:arch:-:hash:"
          cache-path: "${{ runner.tool_cache }}/flutter/:channel:-:version:-:arch:"
      - run: flutter pub get
      - run: flutter build web --release --base-href /${{ github.event.repository.name }}/
      - uses: JamesIves/github-pages-deploy-action@v4
        with:
          folder: build/web
```

Wait for the workflow to finish.
You can see when it is done from the "Actions" tab on the repository page for
your project on GitHub.

When done:

1. Go to "Settings"
2. Click "Pages" in left menu
3. Set "Branch" to "gh-pages"

![Deploy branch "gh-pages"](../images/github-pages-settings.png)

{{% hint info %}}
You won't see the "gh-pages" branch before the workflow has completed.
{{% /hint %}}

You can then make a link to your deployed app in the "About" section on the
repository page.

![Link to website](../images/github-pages-link.png)
