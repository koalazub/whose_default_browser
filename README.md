# WhoseDefaultBrowser


This is a quick script to set the default browser based on the list of browsers you have installed on your machine

## Installation

### Nix

Run this command to get it going

```nix
nix build .#WhoseDefaultBrowser
```

> Note: if you get an issue such as: error: unknown argument: '-march=armv8.3-
then it could mean that you have a mismatch between the Swift compilers' version or it might not be fully compatible with your hardware. This actually could be because the Swift version being used in the flake is too old. 
Read on below to just output a build if you're using an OS outside of NixOS

### Binary
You can build using the following command: 

```swift
  swiftc -o <whatever name you want> main.swift
```


Then you can add it to your path by: 

```bash
  # For bash
  export PATH="$HOME/bin:$PATH"
```

```nushell
  # In nushell
  let-env PATH = ($env.PATH append "/usr/local/bin")
```

> make sure you've got a `~/bin` directory **or** make sure you reference it in the right spot

### Permissions

Make sure you set your permissions correctly:

`chmod +x /bin/WhoseDefaultBrowser`

> remember that this is the path to where you put the binary 

## Usage


```
./WhoseDefaultBrowser  
```

will then output a list of available browsers: 
```
  canary
* safari
  chrome 
```

then:
```
  ./WhoseDefaultBrowser canary
```

**Annoyingly** there's an annoying dialog box and I have no idea how to bypass it. So it's up to you to ascertain whether it's something you're willing to put up with. Or, if you have a solution, please send a PR.


### Problems

I can't get edge to show up in the list of bundleIDs. Haven't digged into why, but you can still set it by entering:

```swift
  // whatever the build name is 
  ./browser edge
```
