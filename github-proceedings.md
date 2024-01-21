# Github notes for the author

Getting things to work on github:

- make sure there's an `oeinstaller:x.y.z` where `x.y.z` is the OpenEdge version you want to install. Note that f.e. 12.8 is denoted as 12.8.0
- create a `progress.cfg` for just the 4GL development server for `x.y.z`, put this, base64 encoded in a secret called `PROGRESS_CFG_XYZ` (f.e. `PROGRES_CFG_XYZ`).

```
base64 progress-128-compiler.cfg
AUZsdXNzbyBCLlYuAP5/AAABgK37AAAAADC6KRn+fwAA/wCADA2wgLD/ADEyLjggICAgICAgICAg
ICAwMDYyNTkxMTIgIC.this.is.not.a.valid.hash.RUVJQjE0WjZXVEJXMjFMR1JaQVVRRktY
RlNCSFJXT0VIAP+AAAANAACA/w0NDQBTVkZSOUVRUktNNU1aR1KAAA0A/w2AgAAA/w00R0wgRGV2
ZWxvcG1lbnQgU3lzdGVtAAAAAAAAAAAAAAAAAFRodSBKYW4gMTggMTA6NTE6NTYgMjAyNAo=

# copy-paste into the github secret
``` 

- create a `response.ini`, put this in `RESPONSE_INI_XYZ`. Not base64 encoded, just the text.

