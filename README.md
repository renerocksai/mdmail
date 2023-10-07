# mdmail

OK, so I have this use-case where I write mails in neovim, using markdown syntax. I am just much
quicker, I have my telekasten.nvim markdown notes in there, etc.

So I need a way to convert these markdown mails to HTML in a way that works with
Outlook.com in the browser. A simple pandoc conversion does not cut it:

- the styling is awful with the default template
- images are not embedded by default

**mdmail** fixes that for me.

I just run `mdmail mail.md` and a beautiful mail with all images and screenshots
embedded will open in my browser. There, I can ctrl+a select all, copy, and
paste it into outlook in the browser.

Ta-dah! 😊

