---
title: macOS
weight: 2
---

# Instructions

<iframe src="https://easv.cloud.panopto.eu/Panopto/Pages/Embed.aspx?id=c2a6f1e2-dca0-4462-96a0-b0d100e54e5b&autoplay=false&offerviewer=true&showtitle=true&showbrand=true&captions=false&interactivity=all" height="405" width="720" style="border: 1px solid #464646;" allowfullscreen allow="autoplay" aria-label="Panopto Embedded Video Player" aria-description="Install Flutter on macOS" ></iframe>

## Prerequisite

Open "Terminal" app (you can just search in spotlight).

Type `git` to verify that you have GIT installed.
If you don't have it will ask you if you want to install developer tools, go
ahead and do that.

If you are on the new Apple Silicon Mac you need to install the translation layer for x86 code.

```sh
sudo softwareupdate --install-rosetta --agree-to-license
```

## Install Flutter-SDK

Now get flutter directly from github.

{{< hint info >}}
I do not recommend synchronizing Flutter SDK to iCloud.
Please exclude <code>~/flutter</code> or choose a different location.
{{< /hint >}}

```sh
cd ~
git clone https://github.com/flutter/flutter.git -b stable
```

You need to figure out what shell you are using.

```sh
echo $SHELL
```

Edit `$HOME/.bashrc` or `$HOME/.zshrc` depending on the output.
For the rest if the text I'm going to assume you are using zsh so the shell
config is referred to as `.zshrc`.

You can use either `vim` or `nano` to edit the config.
In `nano` you can save with _Control+o_ then exit with _Control+x_.
In `vim` it is _ESCAPE_ then type `:wq` .

Add following line at the end of the file:

```sh
export PATH="$PATH:$HOME/flutter/bin"
```

{{< hint info >}}
If you cloned Flutter to a different folder than your home folder
<code>~</code> then you need to adjust the path above accordingly.
{{< /hint >}}

Close your terminal and open it again.

Run following command to check flutter dependencies:

```sh
flutter doctor
```

Install **Chrome** if missing.

Don't worry about the other issues for now.

---

## iPhone

If you have an iPhone and would like to be able to run Flutter projects on it,
then there is a bit of extra setup you will need to do.

[Flutter on iPhone](../mac/iphone)

---

Next you will install an IDE for Flutter, namely Android Studio.
Don't let the name fool you, as it is great for Flutter development no matter the platform.

# [Continue](../android-studio)
