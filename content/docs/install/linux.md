---
title: Linux
weight: 3
---

# Install on Linux

<iframe src="https://easv.cloud.panopto.eu/Panopto/Pages/Embed.aspx?id=2a6a027b-ab52-455d-a022-b0d00180fc4c&autoplay=false&offerviewer=true&showtitle=true&showbrand=true&captions=false&interactivity=all" height="405" width="720" style="border: 1px solid #464646;" allowfullscreen allow="autoplay" aria-label="Panopto Embedded Video Player" aria-description="Install Flutter on Linux" ></iframe>

Open a terminal.

```sh
cd ~
git clone https://github.com/flutter/flutter.git -b stable
```

You need to figure out what shell you are using.

```sh
echo $SHELL
```

Edit `$HOME/.bashrc` or `$HOME/.zshrc` depending on the output.

Add following line at the end of the file:

```sh
export PATH="$PATH:$HOME/flutter/bin"
```

Logout and back in again.

Install **Chrome** you don't have it already.

If you rather use Chromium instead Chrome, then you also need to add the following to your shells configuration file (`.bashrc` or `.zshrc`).

```sh
export CHROME_EXECUTABLE="`which chromium`"
```

Run:

```sh
flutter doctor
```

You should have a checkmark on the following items

```
[✓] Flutter
[✓] Chrome - develop for the web
```

Next you will install Android toolchain and Android Studio.

# [Continue](../android-studio)
