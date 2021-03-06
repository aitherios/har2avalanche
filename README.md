# har2avalanche

A simple script to convert a har file, generated on Chrome Dev Tools, to Spirent Avalanche action list

## Usage

First open Chrome DevTools an generate a HAR file from your network tab.
cf. [https://developer.chrome.com/devtools/docs/network](https://developer.chrome.com/devtools/docs/network#saving-network-data)

Then convert to a action list file for Avalanche:

```sh
./har2avalanche.rb my-file.har > avalanche.txt
```

You can check [Avalanche documentation](http://kms.spirentcom.com/CSC/Avalanche_WebHelp/index.htm#base/welcome.htm)

## Options

List the options with the --help flag:

```sh
./har2avalanche.rb --help
```

```
Usage: har2avalanche.rb [options]

    -f, --file FILE                  HAR file to be parsed
    -b, --best-try                   Tries the best to simulate reality
                                     flags --with-referer --with-headers
        --include-hosts x,y,z...     Hosts to be whitelisted
        --exclude-hosts x,y,z...     Hosts to be blacklisted
    -R, --with-referer               Add <REFERER> directive
    -H, --with-headers               Add <ADDITIONAL_HEADER> directives
        --include-headers x,y,z...   Headers to be whitelisted
                                     flags --with-headers
        --exclude-headers x,y,z...   Headers to be blacklisted
                                     flags --with-headers

    -h, --help                       Show this message
    -v, --version                    Show version
```
