# har2avalanche

A simple script to convert a har file, generated on Chrome Dev Tools, to Spirent Avalanche action list

## Usage

First open Chrome DevTools an generate a HAR file from your network tab.
cf. [https://developer.chrome.com/devtools/docs/network](https://developer.chrome.com/devtools/docs/network#saving-network-data)

Then convert to a action list file for Avalanche:

```sh
./har2avalanche.rb my-file.har > avalanche.txt
```

## Options

List the options with the --help flag:

```sh
./har2avalanche.rb --help
```

```
Usage: har2avalanche.rb [options]

    -f, --file FILE                  HAR file to be parsed
        --include-hosts x,y,z...     Hosts to be whitelisted
        --exclude-hosts x,y,z...     Hosts to be blacklisted
    -H, --with-headers               Add <ADDITIONAL_HEADER> directives
        --include-headers x,y,z...   Headers to be whitelisted
                                     flags --with-headers
        --exclude-headers x,y,z...   Headers to be blacklisted
                                     flags --with-headers

    -h, --help                       Show this message
    -v, --version                    Show version
```
