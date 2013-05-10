FH-Downloader
=============

MMI Downloader


Requires `nokogiri`
To run this you need to create a `config.yml` file.
Example
<pre>modul_Name :
    url:  "http://www.test.com/index.html"
    user:   "user"
    password: "secret"
    destination: "/user/you"
    css-Filter:  "div.downloads"
    fileType-Filter:
      - "pdf"
      - "class"
      - "zip"
      - "jar"
      - "zip"
      - "rar"
    relative_Path: false</pre>