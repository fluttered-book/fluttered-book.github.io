---
title: Windows
weight: 1
---

# Install on Windows

<iframe src="https://easv.cloud.panopto.eu/Panopto/Pages/Embed.aspx?id=6157cbe0-b7b4-4ad8-8977-b0d100090ca1&autoplay=false&offerviewer=true&showtitle=true&showbrand=true&captions=false&interactivity=all" height="405" width="720" style="border: 1px solid #464646;" allowfullscreen allow="autoplay" aria-label="Panopto Embedded Video Player" aria-description="Install Flutter on Windows" ></iframe>

{{< hint danger >}}
I recommend installing to <code>C:\SDKs</code> instead of your user folder as shown in the
video.
Because Flutter needs to be installed to without spaces in the path.
Your user folder is likely to have spaces in its name.
{{< /hint >}}

Open "GIT Bash"

```sh
cd ~
git clone https://github.com/flutter/flutter.git -b stable
```

Now we need to let the OS know where **flutter** binary is located.

{{< hint info >}}
You will need to translate instructions if your Windows installation is in another language than English.
{{< /hint >}}

Press **Windows** button.
Type **"environment"**.
Select **Edit the system environment variables**.

You should see a window this:

![](images/envvar1.png)

Click **Environment Variables**

![](images/envvar2.png)

Click **Edit** for **Path** variable.

![](images/envvar3.png)

Click **New** and type `C:\SDKs\flutter\bin`

**OK** all the windows to close them.

---> Reboot! <---

Open "GIT Bash" and run `flutter doctor`

If Chrome is missing (as in screenshot), then install it to its default location.

![](images/doctor_missing_chrome.png)

Don't worry about the other issues for now.

# [Continue](../android-studio)
