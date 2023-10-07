# mdmail

I use neovim to write emails in markdown syntax, which I find faster and more
efficient. However, I need a way to convert these markdown emails into HTML
that's compatible with Outlook.com's browser version. The standard pandoc
conversion doesn't work well for me due to poor styling and lack of embedded
images. 

To solve this, I use **mdmail**. By simply running `mdmail mail.md`, it
generates a well-styled email with all images and screenshots embedded, which
opens in my browser. I can then select all, copy, and paste it into Outlook in
the browser.

Ta-dah! 😊


## Run without installing

Use nix, with flakes enabled.

```console
$ nix run sourcehut:~renerocksai/mdmail mymail.md
```

## Installing it

Use nix, with flakes enabled.

```console
$ nix profile install sourcehut:~renerocksai/mdmail
```

Then run it:

```console
$ mdmail mymail.md
```
